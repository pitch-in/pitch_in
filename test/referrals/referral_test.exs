defmodule PitchIn.Referrals.ReferralTest do
  use PitchIn.ModelCase

  alias PitchIn.Referrals.Referral

  @valid_attrs %{email: "foo@example.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Referral.changeset(%Referral{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Referral.changeset(%Referral{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset includes a code" do
    changeset = Referral.changeset(%Referral{}, @valid_attrs)
    referral = apply_changes(changeset)

    assert String.length(referral.code) === 6
  end
end

