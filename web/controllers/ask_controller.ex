require IEx

defmodule PitchIn.AskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign
  alias PitchIn.Issue

  use PitchIn.Auth, protect: [:show, :create, :edit, :update, :delete]
  plug :check_campaign_staff when action in [:show, :create, :edit, :update, :delete]
  plug :verify_campaign_staff when action in [:create, :edit, :update, :delete]

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    render(conn, "campaign_index.html", campaign: campaign, asks: campaign.asks)
  end

  def index(conn, %{"filter" => filter}) do
    profession = like_value(filter["profession"])
    role = like_value(filter["role"])
    state = like_value(filter["state"])
    issue = filter["issue"]

    query =
      from a in Ask,
      select: a,
      join: c in Campaign, on: c.id == a.campaign_id,
      where: ilike(a.profession, ^profession),
      where: ilike(c.state, ^state),
      where: ilike(a.role, ^role),
      where: fragment("""
        ? IN (
          SELECT campaign_id
          FROM issues
          WHERE issue ILIKE ?
        )
      """, c.id, ^like_value(issue))

    asks = Repo.all(query)
    render(conn, "index.html", asks: asks)
  end

  def index(conn, _params) do
    user = conn.assigns.current_user

    if user do
      user = user |> Repo.preload(:pro)

      conn
      |> Map.put(
        :params,
        %{
          "filter" => %{
            "profession" => user.pro.profession,
            "state" => user.pro.address_state
          }
        }
      )
    else
      conn
    end
    |> render("index.html", asks: nil)
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
        |> put_flash(:primary, "Ask created successfully.")
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
        |> put_flash(:primary, "Ask updated successfully.")
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
    |> put_flash(:primary, "Ask deleted successfully.")
    |> redirect(to: campaign_ask_path(conn, :index, campaign))
  end

  defp get_campaign(id) do
    Repo.get!(Campaign, id)
    |> Repo.preload(:asks)
  end

  defp like_value(nil), do: "%"
  defp like_value(value), do: "%#{value}%"

  defp check_campaign_staff(conn, _opts) do
    user_id = conn.assigns.current_user.id
    {campaign_id, _} = Integer.parse(conn.params["campaign_id"])

    staff_query =
      from s in PitchIn.CampaignStaff,
      select: count(s.user_id),
      where: s.campaign_id == ^campaign_id,
      where: s.user_id == ^user_id

    count = Repo.one(staff_query)
    |> IO.inspect

    if count > 0 do
      assign(conn, :is_staff, true)
    else
      assign(conn, :is_staff, false)
    end
  end

  defp verify_campaign_staff(conn, _opts) do
    is_staff = conn.assigs.is_staff

    if is_staff do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:alert, "You don't have access to that page.")
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html")
      |> halt
    end
  end
end
