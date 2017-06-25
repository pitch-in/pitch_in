defmodule PitchIn.Politics.Search do
  @moduledoc """
  Search for campaigns and needs.
  """

  import Ecto.Changeset, only: [put_assoc: 3]
  import Ecto.Query
  alias PitchIn.Repo
  alias PitchIn.Politics.NeedSearch
  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Ask
  alias PitchIn.Web.Skill
  alias PitchIn.Tags.Issue

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

  def search(need_search) do
    query = search_query(need_search)
    {:ok, Repo.all(query)}
  end

  def default_search(nil), do: blank_search()
  def default_search(user) do
    user = user |> Repo.preload(:pro)

    skills = user.pro.profession
    years_experience = 
      if user.pro.experience_starts_at do
        Timex.diff(Timex.today, user.pro.experience_starts_at, :years)
      else
        nil
      end
    issues = NeedSearch.split_list(user.pro.issues)

    %NeedSearch{
      skills: skills,
      years_experience: years_experience,
      issues: issues
    }
  end

  def blank_search do
    %NeedSearch{}
  end

  def empty_search?(search) do
    search == %NeedSearch{}
  end

  defp search_query(filter) do
    campaign_fields = Campaign.__schema__(:fields) 
    ask_fields = Ask.__schema__(:fields) 

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
