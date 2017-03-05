require IEx

defmodule PitchIn.AskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign

  use PitchIn.Auth, protect: [:show, :create, :edit, :update]
  plug :check_campaign_staff when action in [:index, :show, :create, :edit, :update]
  plug :verify_campaign_staff when action in [:create, :edit, :update]

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    active_asks = Enum.filter(campaign.asks, &(!PitchIn.ArchiveReasons.archived?(&1)))
    archived_asks = Enum.filter(campaign.asks, &(PitchIn.ArchiveReasons.archived?(&1)))

    if conn.assigns.is_staff do
      render(conn, "campaign_index.html", campaign: campaign, active_asks: active_asks, archived_asks: archived_asks)
    else
      render(conn, "campaign_activist_index.html", campaign: campaign, active_asks: active_asks, archived_asks: [])
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
      where: is_nil(c.archived_reason),
      where: is_nil(a.archived_reason),
      preload: :campaign

    # Handle issues
    query = 
      if filter["issue"] != "" do
        # Find campaigns with matching issues
        from [a, c] in query,
        where: fragment("""
          ? IN (
            SELECT DISTINCT campaign_id
            FROM issues
            WHERE issue ILIKE ?
          )
          OR ? ILIKE ?
        """,
        c.id, ^like_value(issue),
        c.short_pitch, ^like_value(issue))
      else
        query
      end

    asks = Repo.all(query)

    conn = 
      if filter["create_alert"] do
        user = conn.assigns.current_user

        alert_changeset = 
          user
          |> build_assoc(:search_alerts)
          |> PitchIn.SearchAlert.changeset(filter)

        # Note this may fail, and that's fine.
        Repo.insert(alert_changeset)

        conn
        |> put_flash(:success, "Alert successfully created! You can turn it off at any time under settings.")
      else
        conn
      end

    render(conn, "index.html", asks: asks, show_alert_button: !empty_filter?(filter))
  end

  def index(conn, params) do
    user = conn.assigns.current_user

    if user && !params["clear"] do
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
    |> render("index.html", asks: nil, show_alert_button: false)
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

  defp empty_filter?(filter) do
    all_filters = 
      filter
      |> Map.values
      |> Enum.reduce(&(&1 <> &2))

    all_filters == "" 
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

  defp like_value(nil), do: "%"
  defp like_value(value), do: "%#{value}%"

  defp to_int_or_infinity(nil), do: 100
  defp to_int_or_infinity(""), do: 100
  defp to_int_or_infinity(string) do
    case Float.parse("0" <> string) do
      {float, ""} -> round(float)
      _ -> 100
    end
  end
end
