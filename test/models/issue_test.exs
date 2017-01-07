defmodule PitchIn.IssueTest do
  use PitchIn.ModelCase

  alias PitchIn.Issue

  @valid_attrs %{issue: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Issue.changeset(%Issue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Issue.changeset(%Issue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
