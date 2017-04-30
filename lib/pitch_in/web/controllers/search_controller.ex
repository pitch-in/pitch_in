defmodule PitchIn.Web.SearchController do
  use PitchIn.Web, :controller

  alias PitchIn.Web.Ask
  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Skill
  alias PitchIn.Web.SearchAlert
  alias PitchIn.Web.NeedSearch
  alias PitchIn.Web.Issue
  import Ecto.Changeset, only: [put_assoc: 3]

  use PitchIn.Web.Auth

  @ask_match_rating """
  SELECT
    asks.id,
    COALESCE(e.rating, 0)
    AS rating
  FROM asks
  LEFT JOIN (
    SELECT id, 1 as rating
    FROM asks
    WHERE years_experience <= ?
    AND archived_reason IS NULL
  ) AS e ON asks.id = e.id
  """

  def index(conn, %{"filter" => filter}) do
    user = conn.assigns.current_user

    filter = Map.update!(filter, "issues", &(split_list(&1)))

    search_changeset = 
      %NeedSearch{}
      |> NeedSearch.changeset(filter)
      |> put_assoc(:user, user)

    # Note this may fail, and that's fine.
    case Repo.insert(search_changeset) do
      {:ok, search} ->
        results = sort_campaigns(search)
        search_changeset = 
          search_changeset
          |> Ecto.Changeset.apply_changes
          |> NeedSearch.changeset

        conn
        |> handle_alert(user, filter)
        |> render("index.html", changeset: search_changeset, results: results, show_alert_button: !empty_search?(filter))
      {:error, search_changeset} ->
        conn
        |> render("index.html", changeset: search_changeset, show_alert_button: false)
    end
  end

  def index(conn, params) do
    search = make_search(conn, params)
    search_changeset = NeedSearch.changeset(search)

    results = sort_campaigns(search)

    conn
    |> render("index.html", changeset: search_changeset, results: results, show_alert_button: false)
  end
  
  defp make_search(conn, params) do
    user = conn.assigns.current_user
    if user && !params["clear"] do
      user = user |> Repo.preload(:pro)

      skills = user.pro.profession
      years_experience = 
        if user.pro.experience_starts_at do
          Timex.diff(Timex.today, user.pro.experience_starts_at, :years)
        else
          nil
        end
      issues = split_list(user.pro.issues)

      %NeedSearch{
        skills: skills,
        years_experience: years_experience,
        issues: issues
      }
    else
      %NeedSearch{}
    end
  end

  defp split_list(nil), do: []
  defp split_list(string) do
    String.split(string, ~r/\s*,\s*/, trim: true)
  end

  defp handle_alert(conn, user, filter) do
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
  end

  defp empty_search?(search) do
    search == %NeedSearch{}
  end

  defp sort_campaigns(filter) do
    campaign_fields = Campaign.__schema__(:fields) 
    ask_fields = Ask.__schema__(:fields) 

    query =
      from c in Campaign,
      left_join: ask in subquery(ask_subquery), on: c.id == ask.campaign_id,
      left_join: issue_count in (filter |> issue_count_subquery |> subquery), on: c.id == issue_count.id,
      left_join: skill_count in (filter |> skill_count_subquery |> subquery), on: ask.id == skill_count.id,
      left_join: skills in (skill_display_subquery |> subquery), on: ask.id == skills.id,
      left_join: ask_match_rating in (filter |> ask_match_rating_subquery |> subquery), on: ask.id == ask_match_rating.id,
      where: is_nil(c.archived_reason),
      select: %{campaign: c, ask: ask, skills: skills},
      order_by: [
        desc: fragment("COALESCE(?, 0) + COALESCE(?, 0) + COALESCE(?, 0)", issue_count.count, skill_count.count, ask_match_rating.rating),
        desc: fragment("COALESCE(?, ?)", ask.inserted_at, c.inserted_at)
      ]

    Repo.all(query)
  end

  defp ask_subquery do
    from a in Ask,
    where: is_nil(a.archived_reason)
  end

  defp ask_match_rating_subquery(filter) do
    years_experience = to_int_or_infinity(filter.years_experience)

    from a in Ask,
    join: r in fragment(@ask_match_rating, ^years_experience), on: a.id == r.id,
    select: %{id: r.id, rating: r.rating}
  end

  defp skill_count_subquery(search) do
    skills = (search.skills || "") |> String.split(",")

    from s in Skill,
    select: %{id: s.ask_id, count: count(s.ask_id)},
    where: fragment("? ilike any (?)", s.skill, ^skills),
    group_by: s.ask_id
  end

  defp skill_display_subquery do
    from s in Skill,
    select: %{id: s.ask_id, skills: fragment("string_agg(skill, ', ')")},
    group_by: s.ask_id
  end

  defp issue_count_subquery(search) do
    from i in Issue,
    select: %{id: i.campaign_id, count: count(i.campaign_id)},
    where: fragment("? ilike any (?)", i.issue, ^search.issues),
    group_by: i.campaign_id
  end

  defp to_in_list(list) do
    items = Enum.join(list, ", ")
    "(#{items})"
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
end
