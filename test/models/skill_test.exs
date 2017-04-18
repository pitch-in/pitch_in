defmodule PitchIn.SkillTest do
  use PitchIn.ModelCase

  alias PitchIn.Skill

  @valid_attrs %{skill: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Skill.changeset(%Skill{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Skill.changeset(%Skill{}, @invalid_attrs)
    refute changeset.valid?
  end
end
