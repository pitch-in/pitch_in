defmodule PitchIn.ForgotPasswordTest do
  use PitchIn.ModelCase

  alias PitchIn.ForgotPassword

  @valid_attrs %{token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ForgotPassword.changeset(%ForgotPassword{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ForgotPassword.changeset(%ForgotPassword{}, @invalid_attrs)
    refute changeset.valid?
  end
end
