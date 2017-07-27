defmodule PitchIn.AskTest do
  use PitchIn.ModelCase

  alias PitchIn.Web.Ask

  @valid_attrs %{description: "some content", experience: 42, length: 42, profession: "some content", role: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Ask.changeset(%Ask{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Ask.changeset(%Ask{}, @invalid_attrs)
    refute changeset.valid?
  end
end
