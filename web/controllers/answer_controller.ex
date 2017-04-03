defmodule PitchIn.AnswerController do
  use PitchIn.Web, :controller

  alias Plug.Conn
  alias PitchIn.Campaign
  alias PitchIn.Ask
  alias PitchIn.Answer
  alias PitchIn.Email
  alias PitchIn.Mailer
  alias PitchIn.Auth

  use PitchIn.Auth, protect: [:index, :edit, :update, :interstitial]
  plug :check_campaign_staff
  plug :verify_campaign_staff when action in [:index]
  plug :get_answer when action in [:show, :interstitial]

  def index(conn, %{"campaign_id" => _campaign_id, "ask_id" => ask_id}) do
    ask = 
      Repo.get(Ask, ask_id)
      |> Repo.preload(answers: [user: :pro])
      |> Repo.preload(:campaign)
    campaign = ask.campaign

    answers = ask.answers

    if ask.campaign_id == campaign.id do
      render(conn, "index.html", campaign: campaign, ask: ask, answers: answers)
    else
      conn
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html", layout: false)
    end
  end

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = 
      Repo.get(Campaign, campaign_id)
      |> Repo.preload([answers: [:ask, [user: :pro]]])
      |> Repo.preload([direct_answers: [:ask, [user: :pro]]])
    answers = campaign.answers
    direct_answers = campaign.direct_answers

    render(conn, "campaign_index.html", campaign: campaign, answers: answers, direct_answers: direct_answers)
  end

  def volunteer_index(conn, _params) do
    user =
      conn.assigns.current_user
      |> Repo.preload([answers: [:ask, :campaign, :direct_campaign]])

    render(conn, "volunteer_index.html", answers: user.answers)
  end

  def new(conn, %{"campaign_id" => _campaign_id, "ask_id" => ask_id}) do
    ask = Repo.get(Ask, ask_id) |> Repo.preload(:campaign)
    campaign = ask.campaign

    case Conn.get_session(conn, :answer_params) do
      nil ->
        changeset =
          ask
          |> build_assoc(:answers)
          |> Answer.changeset
          
        render(conn, "show.html", campaign: campaign, ask: ask, changeset: changeset)
      answer_params -> create_from_session(conn, answer_params)
    end
  end

  def new(conn, %{"campaign_id" => campaign_id}) do
    campaign = Repo.get(Campaign, campaign_id)

    case Conn.get_session(conn, :answer_params) do
      nil ->
        changeset =
          campaign
          |> build_assoc(:direct_answers)
          |> Answer.changeset
          
        render(conn, "show.html", campaign: campaign, ask: nil, changeset: changeset)
      answer_params -> create_from_session(conn, answer_params)
    end
  end

  def create(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "answer" => answer_params
    } = params) do
  
    if !conn.assigns.current_user do
      handle_anonymous_create(conn, params)
    else
      ask = Repo.get(Ask, ask_id) |> Repo.preload(:campaign)
      campaign = ask.campaign
      
      changeset =
        ask
        |> build_assoc(:answers)
        |> Answer.changeset(answer_params)
        |> Ecto.Changeset.put_assoc(:user, conn.assigns.current_user)

      case Repo.insert(changeset) do
        {:ok, answer} ->
          answer = answer |> Repo.preload(user: :pro)
          send_answer_emails(conn, campaign, ask, answer)

          conn
          |> redirect(to: campaign_ask_answer_path(conn, :interstitial, campaign, ask, answer))
        {:error, changeset} ->
          render(conn, "show.html", campaign: campaign, ask: ask, changeset: changeset)
      end
    end
  end

  def create(conn,
    %{
      "campaign_id" => campaign_id,
      "answer" => answer_params
    } = params) do
  
    if !conn.assigns.current_user do
      handle_anonymous_create(conn, params)
    else
      campaign = Repo.get(Campaign, campaign_id)
      
      changeset =
        %Answer{}
        |> Answer.changeset(answer_params)
        |> Ecto.Changeset.put_assoc(:direct_campaign, campaign)
        |> Ecto.Changeset.put_assoc(:user, conn.assigns.current_user)

      case Repo.insert(changeset) do
        {:ok, answer} ->
          answer = answer |> Repo.preload(user: :pro)
          send_answer_emails(conn, campaign, nil, answer)

          conn
          |> redirect(to: campaign_answer_path(conn, :interstitial, campaign, answer))
        {:error, changeset} ->
          render(conn, "show.html", campaign: campaign, ask: nil, changeset: changeset)
      end
    end
  end

  def interstitial(conn,
    %{
      "campaign_id" => _campaign_id,
      "id" => _id
    }) do
    answer = conn.assigns.answer
    ask = conn.assigns.ask
    campaign = conn.assigns.campaign

    render(conn, "interstitial.html", campaign: campaign, ask: ask, answer: answer)
  end

  def show(conn,
    %{
      "campaign_id" => _campaign_id,
      "id" => _id
    }) do
    answer = conn.assigns.answer
    ask = conn.assigns.ask
    campaign = conn.assigns.campaign

    if conn.assigns.is_owner do
      render(conn, "show.html", campaign: campaign, ask: ask, answer: answer)
    else
      render(conn, "show_to_campaign.html", campaign: campaign, ask: ask, answer: answer)
    end
  end

  defp get_answer(conn, _opts) do
    id = conn.params["id"]

    answer = Repo.one(
      from a in Answer,
      where: a.id == ^id,
      preload: [ask: :campaign],
      preload: :direct_campaign,
      preload: [user: :pro]
    )

    campaign = if answer.ask, do: answer.ask.campaign, else: answer.direct_campaign

    is_owner = answer && answer.user_id == conn.assigns.current_user.id
    is_staff = conn.assigns.is_staff
    is_correct_campaign = campaign && Integer.to_string(campaign.id) == conn.params["campaign_id"]

    if is_correct_campaign && (is_owner || is_staff) do
      conn
      |> Conn.assign(:answer, answer)
      |> Conn.assign(:campaign, campaign)
      |> Conn.assign(:ask, answer.ask)
      |> Conn.assign(:is_owner, is_owner)
    else
      conn
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html", layout: false)
      |> halt
    end
  end

  defp handle_anonymous_create(conn, params) do
    deep_path = 
      case params["ask_id"] do
        nil -> campaign_answer_path(conn, :new, params["campaign_id"])
        ask_id -> campaign_ask_answer_path(conn, :new, params["campaign_id"], ask_id)
      end
    
    conn
    |> Conn.put_session(:answer_params, params)
    |> Auth.deep_link_redirect(deep_path)
  end

  defp create_from_session(conn, answer_params) do
    conn = 
      conn
      |> Conn.delete_session(:answer_params)

    create(conn, answer_params)
  end

  defp send_answer_emails(conn, campaign, ask, answer) do
    Email.user_answer_email(
      conn.assigns.current_user.email,
      conn,
      campaign,
      ask,
      answer
    )
    |> Mailer.deliver_later

    Email.campaign_answer_email(
      campaign.email,
      conn,
      campaign,
      ask,
      answer
    )
    |> Mailer.deliver_later
  end
end
