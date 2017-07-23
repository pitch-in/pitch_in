defmodule PitchIn.Referrals.ReferralTest do
  use PitchIn.DataCase

  alias PitchIn.Referrals
  alias PitchIn.Referrals.Referral
  alias PitchIn.Web.User

  describe "add_referral" do
    test "adds the referral" do
      referrer = insert!(:user)
      email = "test@example.com"
      
      assert {:ok, %Referral{referrer: referrer, email: email}} = Referrals.add_referral(referrer, email)
    end
  end

  # describe "list_issues" do
  #   setup do
  #     insert!(:issue, issue: "other")
  #     insert!(:issue, issue: "testing")
  #     insert!(:issue, issue: "testing")
  #     :ok
  #   end

  #   test "list_issues/0 returns all issues" do
  #     assert Tags.list_issues() == ["testing", "other"]
  #   end

  #   test "list_issues/1 returns filtered issues" do
  #     assert Tags.list_issues(filter: "the") == ["other"]
  #   end
  # end

end

