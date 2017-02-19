defmodule PitchIn.SearchAlertTest do
  use PitchIn.ModelCase

  alias PitchIn.SearchAlert

  @valid_attrs %{issue: "some content", profession: "some content", role: "some content", years_experience: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SearchAlert.changeset(%SearchAlert{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SearchAlert.changeset(%SearchAlert{}, @invalid_attrs)
    refute changeset.valid?
  end
end
