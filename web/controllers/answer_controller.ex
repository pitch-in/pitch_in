defmodule PitchIn.AnswerController do
  use PitchIn.Web, :controller

  alias PitchIn.Campaign
  alias PitchIn.Ask
  alias PitchIn.Answer
  alias PitchIn.Email
  alias PitchIn.Mailer

  use PitchIn.Auth, protect: :all
  plug :check_campaign_staff
  plug :verify_campaign_staff when action in [:index]
  plug :get_answer when action in [:show, :edit, :update, :delete]

  def index(conn, %{"campaign_id" => campaign_id, "ask_id" => ask_id}) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id) |> Repo.preload(answers: [user: :pro])
    answers = ask.answers

    if ask.campaign_id == campaign.id do
      render(conn, "index.html", campaign: campaign, ask: ask, answers: answers)
    else
      conn
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html")
    end
  end

  def new(conn, %{"campaign_id" => campaign_id, "ask_id" => ask_id}) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)

    changeset =
      ask
      |> build_assoc(:answers)
      |> Answer.changeset
      
    render(conn, "new.html", campaign: campaign, ask: ask, changeset: changeset)
  end

  def create(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "answer" => answer_params
    }) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)
    
    changeset =
      ask
      |> build_assoc(:answers)
      |> Answer.changeset(answer_params)
      |> Ecto.Changeset.put_assoc(:user, conn.assigns.current_user)

    case Repo.insert(changeset) do
      {:ok, answer} ->
        answer = answer |> Repo.preload(user: :pro)

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

        conn
        |> put_flash(:primary, "Answer created successfully.")
        |> redirect(to: campaign_ask_answer_path(conn, :show, campaign, ask, answer))
      {:error, changeset} ->
        render(conn, "new.html", campaign: campaign, ask: ask, changeset: changeset)
    end
  end

  def show(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "id" => id
    }) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)
    answer = conn.assigns.answer |> Repo.preload([user: :pro])

    render(conn, "show.html", campaign: campaign, ask: ask, answer: answer)
  end

  def edit(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "id" => id
    }) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)
    answer = conn.assigns.answer

    changeset = Answer.changeset(answer)
    render(conn, "edit.html", campaign: campaign, ask: ask, answer: answer, changeset: changeset)
  end

  def update(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "id" => id,
      "answer" => answer_params
    }) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)
    answer = conn.assigns.answer

    changeset = Answer.changeset(answer, answer_params)

    case Repo.update(changeset) do
      {:ok, answer} ->
        conn
        |> put_flash(:primary, "Answer updated successfully.")
        |> redirect(to: campaign_ask_answer_path(conn, :show, campaign, ask, answer))
      {:error, changeset} ->
        render(conn, "edit.html", campaign: campaign, ask: ask, answer: answer, changeset: changeset)
    end
  end

  def delete(conn,
    %{
      "campaign_id" => campaign_id,
      "ask_id" => ask_id,
      "id" => id
    }) do
    campaign = Repo.get(Campaign, campaign_id)
    ask = Repo.get(Ask, ask_id)
    answer = conn.assigns.answer

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(answer)

    conn
    |> put_flash(:primary, "Answer deleted successfully.")
    |> redirect(to: campaign_ask_answer_path(conn, :index, campaign, ask))
  end

  defp get_answer(conn, _opts) do
    id = conn.params["id"]
    answer = Repo.get!(Answer, id)
    IO.puts("--------USER_IDS-----------")
    IO.puts("CURRENT: #{conn.assigns.current_user.id}")
    IO.puts("OWNER: #{answer.user_id}")

    conn
    |> Plug.Conn.assign(:answer, answer)
    |> Plug.Conn.assign(:is_owner, answer.user_id == conn.assigns.current_user.id)
  end
end
