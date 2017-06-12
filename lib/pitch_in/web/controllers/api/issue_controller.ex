defmodule PitchIn.Web.Api.IssueController do
  use PitchIn.Web, :controller

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue

  action_fallback PitchIn.Web.FallbackController

  def index(conn, params) do
    filter = Map.get(params, "filter", "")
    issues = Tags.list_issues(filter: filter)

    render(conn, "index.json", issues: issues)
  end
end

