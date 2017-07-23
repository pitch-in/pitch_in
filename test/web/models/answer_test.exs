defmodule PitchIn.AnswerTest do
  use PitchIn.ModelCase

  alias PitchIn.Web.Answer

  @valid_attrs %{message: "some content", share_address: true, share_email: true, share_phone: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Answer.changeset(%Answer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Answer.changeset(%Answer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
