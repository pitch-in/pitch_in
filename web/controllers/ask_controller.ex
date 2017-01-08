require IEx

defmodule PitchIn.AskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    render(conn, "campaign_index.html", campaign: campaign, asks: campaign.asks)
  end

  def index(conn, _params) do
    asks = Repo.all(Ask)
    render(conn, "index.html", asks: asks)
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
        |> put_flash(:info, "Ask created successfully.")
        |> redirect(to: campaign_ask_path(conn, :edit, campaign, ask))
      {:error, changeset} ->
        render(conn, "new.html", campaign: campaign, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ask = Repo.get!(Ask, id)
    render(conn, "show.html", ask: ask)
  end

  def edit(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    campaign = get_campaign(campaign_id)
    ask = Repo.get!(Ask, id)
    changeset = Ask.changeset(ask)
    render(conn, "edit.html", campaign: campaign, ask: ask, changeset: changeset)
  end

  def update(conn, %{"campaign_id" => campaign_id, "id" => id, "ask" => ask_params}) do
    campaign = get_campaign(campaign_id)
    ask = Repo.get!(Ask, id)
    changeset = Ask.changeset(ask, ask_params)

    case Repo.update(changeset) do
      {:ok, ask} ->
        conn
        |> put_flash(:info, "Ask updated successfully.")
        |> redirect(to: campaign_ask_path(conn, :edit, campaign, ask))
      {:error, changeset} ->
        render(conn, "edit.html", ask: ask, campaign: campaign, changeset: changeset)
    end
  end

  def delete(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    campaign = get_campaign(campaign_id)
    ask = Repo.get!(Ask, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ask)

    conn
    |> put_flash(:info, "Ask deleted successfully.")
    |> redirect(to: campaign_ask_path(conn, :index, campaign))
  end

  defp get_campaign(id) do
    Repo.get!(Campaign, id)
    |> Repo.preload(:asks)
  end
end
