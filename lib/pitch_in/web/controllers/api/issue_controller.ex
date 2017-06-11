defmodule PitchIn.Web.Api.IssueController do
  use PitchIn.Web, :controller

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue

  action_fallback PitchIn.Web.FallbackController

  def index(conn, _params) do
    issues = Tags.list_issues()
    render(conn, "index.json", issues: issues)
  end

  def create(conn, %{"issue" => issue_params}) do
    with {:ok, %Issue{} = issue} <- Tags.create_issue(issue_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", api_issue_path(conn, :show, issue))
      |> render("show.json", issue: issue)
    end
  end

  def show(conn, %{"id" => id}) do
    issue = Tags.get_issue!(id)
    render(conn, "show.json", issue: issue)
  end

  def update(conn, %{"id" => id, "issue" => issue_params}) do
    issue = Tags.get_issue!(id)

    with {:ok, %Issue{} = issue} <- Tags.update_issue(issue, issue_params) do
      render(conn, "show.json", issue: issue)
    end
  end

  def delete(conn, %{"id" => id}) do
    issue = Tags.get_issue!(id)
    with {:ok, %Issue{}} <- Tags.delete_issue(issue) do
      send_resp(conn, :no_content, "")
    end
  end
end

