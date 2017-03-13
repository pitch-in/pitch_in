defmodule PitchIn.SearchController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign
  alias PitchIn.SearchAlert
  alias PitchIn.NeedSearch
  alias PitchIn.Issue
  import Ecto.Changeset, only: [put_assoc: 3]

  use PitchIn.Auth

  def index(conn, %{"filter" => filter}) do
    user = conn.assigns.current_user
    campaigns = sort_campaigns(filter)

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

    render(conn, "index.html", campaigns: campaigns, show_alert_button: !empty_filter?(filter))
  end

  def index(conn, params) do
    user = conn.assigns.current_user
    campaigns = sort_campaigns(%{})

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
    |> render("index.html", campaigns: campaigns, show_alert_button: false)
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
    query =
      from c in Campaign,
      left_join: need in (filter |> matching_ask_subquery |> subquery), on: c.id == need.campaign_id,
      left_join: issue_count in (filter |> issue_count_subquery |> subquery), on: c.id == issue_count.id,
      left_join: need_count in (filter |> matching_ask_count_subquery |> subquery), on: c.id == need_count.id,
      where: is_nil(c.archived_reason),
      preload: :asks,
      order_by: [
        fragment("? DESC NULLS LAST", need_count.count),
        fragment("? DESC NULLS LAST", issue_count.count),
        desc: c.inserted_at
      ]

    Repo.all(query)
  end

  defp matching_ask_subquery(filter) do
    profession = like_value(filter["profession"])
    years_experience = to_int_or_infinity(filter["years_experience"], 1)

    from a in Ask,
    where: ilike(a.profession, ^profession),
    where: a.years_experience <= ^years_experience,
    where: is_nil(a.archived_reason)
  end

  defp matching_ask_count_subquery(filter) do
    ask_query = matching_ask_subquery(filter)

    from a in ask_query,
    select: %{id: a.campaign_id, count: count(a.campaign_id)},
    group_by: a.campaign_id
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
