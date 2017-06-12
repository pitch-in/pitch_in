defmodule PitchIn.Web.Api.IssueView do
  use PitchIn.Web, :view
  alias PitchIn.Web.Api.IssueView

  def render("index.json", %{issues: issues}) do
    %{data: render_many(issues, IssueView, "issue.json")}
  end

  def render("issue.json", %{issue: issue}) do
    issue
  end
end
