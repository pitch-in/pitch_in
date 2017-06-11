defmodule PitchIn.Tags do
  @moduledoc """
  The boundary for the Tags system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Tags.Issue

  @doc """
  Returns the list of issues.

  ## Examples

      iex> list_issues()
      [%Issue{}, ...]

  """
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
end
