defmodule PitchIn.Web.IssueView do
  use PitchIn.Web, :view
  alias PitchIn.Tags.IssueView

  def render("index.json", %{issues: issues}) do
    %{data: render_many(issues, IssueView, "issue.json")}
  end

  def render("show.json", %{issue: issue}) do
    %{data: render_one(issue, IssueView, "issue.json")}
  end

  def render("issue.json", %{issue: issue}) do
    %{id: issue.id,
      value: issue.value}
  end
end
