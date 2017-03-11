defmodule PitchIn.AskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign

  use PitchIn.Auth, protect: :all
  plug :check_campaign_staff
  plug :verify_campaign_staff

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    active_asks = Enum.filter(campaign.asks, &(!PitchIn.ArchiveReasons.archived?(&1)))
    archived_asks = 
      if conn.assigns.is_staff do
        Enum.filter(campaign.asks, &(PitchIn.ArchiveReasons.archived?(&1)))
      else
        []
      end

    render(conn, "campaign_index.html", campaign: campaign, active_asks: active_asks, archived_asks: archived_asks)
  end

  def new(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)
    changeset =
      campaign
      |> build_assoc(:asks)
      |> Ask.changeset

    render(conn, "new.html", campaign: campaign, changeset: changeset)
  end

  def create(conn, %{"campaign_id" => campaign_id, "ask" => ask_params}) do
    campaign = get_campaign(campaign_id)
    changeset =
      campaign
      |> build_assoc(:asks)
      |> Ask.changeset(ask_params)

    case Repo.insert(changeset) do
      {:ok, ask} ->
        conn
        |> redirect(to: campaign_ask_path(conn, :interstitial, campaign, ask))
      {:error, changeset} ->
        render(conn, "new.html", campaign: campaign, changeset: changeset)
    end
  end

  def interstitial(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    ask = get_ask(campaign_id, id)
    render(conn, "interstitial.html", ask: ask)
  end

  def show(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    ask = get_ask(campaign_id, id)
    render(conn, "show.html", campaign: ask.campaign, ask: ask)
  end

  def edit(conn, %{"campaign_id" => campaign_id, "id" => id, "archive" => "true"}) do
    ask = get_ask(campaign_id, id)

    changeset = Ask.archive_changeset(ask)
    render(conn, "edit_archived.html", campaign: ask.campaign, ask: ask, changeset: changeset)
  end

  def edit(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    ask = get_ask(campaign_id, id)

    changeset = Ask.changeset(ask)
    render(conn, "edit.html", campaign: ask.campaign, ask: ask, changeset: changeset)
  end

  def update(conn, %{"campaign_id" => campaign_id, "id" => id, "ask" => ask_params, "archive" => "true"}) do
    ask = get_ask(campaign_id, id)
    changeset = Ask.archive_changeset(ask, ask_params)

    case Repo.update(changeset) do
      {:ok, %{archived_reason: nil} = ask} ->
        conn
        |> put_flash(:success, "Need successfully unarchived!")
        |> redirect(to: campaign_ask_path(conn, :edit, ask.campaign, ask))
      {:ok, %{archived_reason: _} = ask} ->
        conn
        |> put_flash(:warning, "Need successfully archived.")
        |> redirect(to: campaign_ask_path(conn, :show, ask.campaign, ask))
      {:error, changeset} ->
        render(conn, "edit.html", ask: ask, campaign: ask.campaign, changeset: changeset)
    end
  end

  def update(conn, %{"campaign_id" => campaign_id, "id" => id, "ask" => ask_params}) do
    ask = get_ask(campaign_id, id)
    changeset = Ask.changeset(ask, ask_params)

    case Repo.update(changeset) do
      {:ok, ask} ->
        conn
        |> put_flash(:success, "Need updated successfully.")
        |> redirect(to: campaign_ask_path(conn, :edit, ask.campaign, ask))
      {:error, changeset} ->
        render(conn, "edit.html", ask: ask, campaign: ask.campaign, changeset: changeset)
    end
  end

  defp get_ask(campaign_id, id) do
    Repo.one(
      from a in Ask,
      where: a.id == ^id,
      where: a.campaign_id == ^campaign_id,
      preload: :campaign
    )
  end

  defp get_campaign(id) do
    Repo.get!(Campaign, id)
    |> Repo.preload(:asks)
  end
end
