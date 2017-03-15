defmodule PitchIn.SearchController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign
  alias PitchIn.SearchAlert
  alias PitchIn.NeedSearch
  alias PitchIn.Issue
  import Ecto.Changeset, only: [put_assoc: 3]

  use PitchIn.Auth

  @ask_match_rating """
  SELECT
    asks.id,
    COALESCE(p.rating, 0) + COALESCE(e.rating, 0)
    AS rating
  FROM asks
  LEFT JOIN (
    SELECT id, 1 AS rating
    FROM asks
    WHERE profession = ?
    AND archived_reason IS NULL
  ) AS p ON asks.id = p.id
  LEFT JOIN (
    SELECT id, 1 as rating
    FROM asks
    WHERE years_experience <= ?
    AND archived_reason IS NULL
  ) AS e ON asks.id = e.id
  """

  def index(conn, %{"filter" => filter}) do
    user = conn.assigns.current_user
    results = sort_campaigns(filter)

    search_changeset = 
      %NeedSearch{}
      |> NeedSearch.changeset(filter)
      |> put_assoc(:user, user)

    # Note this may fail, and that's fine.
    Repo.insert(search_changeset)

    conn = 
      if filter["create_alert"] do
        alert_changeset = 
          %SearchAlert{}
          |> SearchAlert.changeset(filter)
          |> put_assoc(:user, user)

        # Note this may fail, and that's fine.
        Repo.insert(alert_changeset)

        conn
        |> put_flash(:success, "Alert successfully created! You can turn it off at any time under settings.")
      else
        conn
      end

    render(conn, "index.html", results: results, show_alert_button: !empty_filter?(filter))
  end

  def index(conn, params) do
    user = conn.assigns.current_user
    results = sort_campaigns(%{})

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
    |> render("index.html", results: results, show_alert_button: false)
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

  defp to_int_or_infinity(number), do: to_int_or_infinity(number, 0)
  defp to_int_or_infinity(nil, _), do: 100
  defp to_int_or_infinity("", _), do: 100
  defp to_int_or_infinity(int, plus) when is_integer(int), do: int + plus
  defp to_int_or_infinity(string, plus) do
    case Float.parse("0" <> string) do
      {float, ""} -> round(float) + plus
      _ -> 100
    end
  end

  defp sort_campaigns(filter) do
    campaign_fields = Campaign.__schema__(:fields) 
    ask_fields = Ask.__schema__(:fields) 

    query =
      from c in Campaign,
      left_join: ask in subquery(ask_subquery), on: c.id == ask.campaign_id,
      left_join: issue_count in (filter |> issue_count_subquery |> subquery), on: c.id == issue_count.id,
      left_join: ask_match_rating in (filter |> ask_match_rating_subquery |> subquery), on: ask.id == ask_match_rating.id,
      where: is_nil(c.archived_reason),
      select: %{campaign: c, ask: ask},
      order_by: [
        desc: fragment("COALESCE(?, 0) + COALESCE(?, 0)", issue_count.count, ask_match_rating.rating),
        desc: fragment("COALESCE(?, ?)", ask.inserted_at, c.inserted_at)
      ]

    Repo.all(query)
  end

  defp ask_subquery do
    from a in Ask,
    where: is_nil(a.archived_reason)
  end

  defp ask_match_rating_subquery(filter) do
    profession = filter["profession"]
    years_experience = to_int_or_infinity(filter["years_experience"], 1)

    from a in Ask,
    join: r in fragment(@ask_match_rating, ^profession, ^years_experience), on: a.id == r.id,
    select: %{id: r.id, rating: r.rating}
  end

  defp issue_count_subquery(filter) do
    issue = filter["issue"] || ""

    from i in Issue,
    select: %{id: i.campaign_id, count: count(i.campaign_id)},
    where: i.issue == ^issue,
    group_by: i.campaign_id
  end

  defp to_in_list(list) do
    items = Enum.join(list, ", ")
    "(#{items})"
  end
end
