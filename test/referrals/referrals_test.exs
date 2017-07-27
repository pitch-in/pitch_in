defmodule PitchIn.Referrals.ReferralTest do
  use PitchIn.DataCase

  alias PitchIn.Referrals
  alias PitchIn.Referrals.Referral
  alias PitchIn.Web.User

  describe "add_referral" do
    setup do
      referrer = insert!(:user)
      email = "test@example.com"

      {:ok, referrer: referrer, email: email}
    end

    test "adds the referral", %{referrer: referrer, email: email} do
      assert {:ok, %Referral{referrer: referrer, email: email}} = Referrals.add_referral(referrer, email)
    end
  end


  describe "list_issues" do
    setup do
      user = insert!(:user)
      other_user = insert!(:user)

      insert!(:referral, referrer: user, email: "one@example.com")
      insert!(:referral, referrer: user, email: "two@example.com")
      insert!(:referral, referrer: other_user, email: "bad@example.com")

      {:ok, user: user}
    end

    test "returns the user's referrals", %{user: user} do
      assert length(Referrals.list_referrals(user)) == 2
    end
  end

  describe "validate_referral" do
    test "error for empty emails" do
      assert {:error, _} = Referrals.validate_referral(%{"email" => ""})
    end

    test "ok for valid emails" do
      email = "foo@example.com"
      assert {:ok, %{email: email}} = Referrals.validate_referral(%{"email" => email})
    end
  end

end

