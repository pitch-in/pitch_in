defmodule PitchIn.Tags do
  @moduledoc """
  The boundary for the Tags system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Tags.Issue
  alias PitchIn.Campaigns.Campaign

  def list_issues(opts \\ []) do
    filter = Keyword.get(opts, :filter, "")
    count = Keyword.get(opts, :count, 10)
    
    filtered_subquery =
      from i in Issue,
      where: ilike(i.issue, ^"%#{filter}%")

    unorderd_query = 
      from i in subquery(filtered_subquery),
      group_by: i.issue,
      select: %{issue: i.issue, count: count(i.issue)},
      limit: 10

    ordered_query = 
      from i in subquery(unorderd_query),
      select: i.issue,
      order_by: [desc: i.count]

    Repo.all(ordered_query)
  end

  def add_issue(%Campaign{} = campaign, value) do
    changeset =
      campaign
      |> build_assoc(:issues)
      |> Issue.changeset(%{issue: value})

    Repo.insert(changeset)
  end

  def clean_up_issues(issues) do
    issues
    # Trim each issue.
    |> Enum.map(fn {i, issue} ->
      issue = Map.update!(issue, "issue", &(String.trim(&1)))
      {i, issue}
    end)
    # Remove blank issues.
    |> Enum.reject(fn {_i, issue} ->
      issue["issue"] == ""
    end)
    |> Enum.into(%{})
  end
end
