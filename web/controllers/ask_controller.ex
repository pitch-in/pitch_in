require IEx

defmodule PitchIn.AskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign
  alias PitchIn.Issue

  use PitchIn.Auth, protect: [:show, :create, :edit, :update, :delete]
  plug :check_campaign_staff when action in [:index, :show, :create, :edit, :update, :delete]
  plug :verify_campaign_staff when action in [:create, :edit, :update, :delete]

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    if conn.assigns.is_staff do
      render(conn, "campaign_index.html", campaign: campaign, asks: campaign.asks)
    else
      render(conn, "campaign_activist_index.html", campaign: campaign, asks: campaign.asks)
    end
  end

  def index(conn, %{"filter" => filter}) do
    profession = like_value(filter["profession"])
    role = like_value(filter["role"])
    years_experience = to_int_or_infinity(filter["years_experience"])
    issue = filter["issue"]

    query =
      from a in Ask,
      select: a,
      join: c in Campaign, on: c.id == a.campaign_id,
      where: ilike(a.profession, ^profession),
      where: ilike(a.role, ^role),
      where: a.years_experience <= ^years_experience,
      where: fragment("""
        ? IN (
          SELECT campaign_id
          FROM issues
          WHERE issue ILIKE ?
        )
      """, c.id, ^like_value(issue)),
      preload: :campaign

    asks = Repo.all(query)
    render(conn, "index.html", asks: asks)
  end

  def index(conn, _params) do
    user = conn.assigns.current_user

    if user do
      user = user |> Repo.preload(:pro)
      years_experience = 
        if user.pro.experience_starts_at do
          Timex.diff(Timex.today, user.pro.experience_starts_at, :years)
        else
          nil
        end

      conn
      |> Map.put(
        :params,
        %{
          "filter" => %{
            "profession" => user.pro.profession,
            "years_experience" => years_experience
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
        |> put_flash(:success, "Ask created successfully.")
        |> redirect(to: campaign_ask_path(conn, :edit, campaign, ask))
      {:error, changeset} ->
        render(conn, "new.html", campaign: campaign, changeset: changeset)
    end
  end

  def show(conn, %{"campaign_id" => campaign_id, "id" => id}) do
    campaign = get_campaign(campaign_id)
    ask = Repo.get!(Ask, id)
    render(conn, "show.html", campaign: campaign, ask: ask)
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
        |> put_flash(:success, "Ask updated successfully.")
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
    |> put_flash(:success, "Ask deleted successfully.")
    |> redirect(to: campaign_ask_path(conn, :index, campaign))
  end

  defp get_campaign(id) do
    Repo.get!(Campaign, id)
    |> Repo.preload(:asks)
  end

  defp like_value(nil), do: "%"
  defp like_value(value), do: "%#{value}%"

  defp to_int_or_infinity(nil), do: 100
  defp to_int_or_infinity(""), do: 100
  defp to_int_or_infinity(string), do: String.to_integer(string)
end
