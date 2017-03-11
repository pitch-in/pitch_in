defmodule PitchIn.SearchController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign
  alias PitchIn.SearchAlert
  alias PitchIn.NeedSearch

  def index(conn, %{"filter" => filter}) do
    user = conn.assigns.current_user
    asks = search_asks(filter)

    search_changeset_params = Map.put(filter, "found_count", length(asks))

    search_changeset = 
      user
      |> build_assoc(:need_searches)
      |> NeedSearch.changeset(search_changeset_params)

    # Note this may fail, and that's fine.
    Repo.insert(search_changeset)

    conn = 
      if filter["create_alert"] do

        alert_changeset = 
          user
          |> build_assoc(:search_alerts)
          |> SearchAlert.changeset(filter)

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
    asks = search_asks(%{})

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
    |> render("index.html", asks: asks, show_alert_button: false)
  end

  defp empty_filter?(filter) do
    all_filters = 
      filter
      |> Map.values
      |> Enum.reduce(&(&1 <> &2))

    all_filters == "" 
  end

  defp like_value(nil), do: "%"
  defp like_value(value), do: "%#{value}%"

  defp to_int_or_infinity(nil), do: 100
  defp to_int_or_infinity(""), do: 100
  defp to_int_or_infinity(int) when is_integer(int), do: int
  defp to_int_or_infinity(string) do
    case Float.parse("0" <> string) do
      {float, ""} -> round(float)
      _ -> 100
    end
  end

  defp search_asks(filter) do
    profession = like_value(filter["profession"])
    years_experience = to_int_or_infinity(filter["years_experience"])
    issue = filter["issue"]

    query =
      from a in Ask,
      select: a,
      join: c in Campaign, on: c.id == a.campaign_id,
      where: ilike(a.profession, ^profession),
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

    Repo.all(query)
  end
end
