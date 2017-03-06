defmodule PitchIn.Admin.DashboardController do
  use PitchIn.Web, :controller

  alias PitchIn.User
  alias PitchIn.Campaign
  alias PitchIn.Ask
  alias PitchIn.Answer
  alias PitchIn.NeedSearch
  alias PitchIn.SearchAlert

  def index(conn, _) do
    users_count = user_query |> full_count
    campaigns_count = full_count(Campaign)
    asks_count = full_count(Ask)
    answers_count = full_count(Answer)
    searches_count = full_count(NeedSearch)
    alerts_count = full_count(SearchAlert)

    new_users_count = user_query |> new_count
    new_campaigns_count = new_count(Campaign)
    new_asks_count = new_count(Ask)
    new_answers_count = new_count(Answer)
    new_searches_count = new_count(NeedSearch)
    new_alerts_count = new_count(SearchAlert)

    render(
      conn,
      "index.html",
      users_count: users_count,
      campaigns_count: campaigns_count,
      asks_count: asks_count,
      answers_count: answers_count,
      searches_count: searches_count,
      alerts_count: alerts_count,

      new_users_count: new_users_count,
      new_campaigns_count: new_campaigns_count,
      new_asks_count: new_asks_count,
      new_answers_count: new_answers_count,
      new_searches_count: new_searches_count,
      new_alerts_count: new_alerts_count
    )
  end

  defp user_query do
    from u in User,
    where: not ilike(u.email, "%@pitch-in.us")
  end

  defp full_count(module), do: Repo.aggregate(module, :count, :id)

  defp new_count(module) do
    twenty_four_hours_ago = 
      Timex.now
      |> Timex.subtract(Timex.Duration.from_hours(24))

    Repo.aggregate(
      (from i in module,
      where: i.inserted_at > ^twenty_four_hours_ago),
      :count, :id
    )
  end
end

