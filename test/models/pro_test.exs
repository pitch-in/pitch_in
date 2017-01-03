defmodule PitchIn.ProTest do
  use PitchIn.ModelCase

  alias PitchIn.Pro

  @valid_attrs %{address_city: "some content", address_state: "some content", address_street: "some content", address_unit: "some content", address_zip: "some content", experience_starts_at: %{day: 17, month: 4, year: 2010}, linkedin_url: "some content", phone: "some content", profession: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pro.changeset(%Pro{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pro.changeset(%Pro{}, @invalid_attrs)
    refute changeset.valid?
  end
end
