defmodule PitchIn.Tags.TagsTest do
  use PitchIn.DataCase

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue
  alias PitchIn.Web.User
  alias PitchIn.Web.Campaign

  describe "list_issues" do
    setup do
      insert!(:issue, issue: "other")
      insert!(:issue, issue: "testing")
      insert!(:issue, issue: "testing")
      :ok
    end

    test "list_issues/0 returns all issues" do
      assert Tags.list_issues() == ["testing", "other"]
    end

    test "list_issues/1 returns filtered issues" do
      assert Tags.list_issues(filter: "the") == ["other"]
    end
  end

  describe "add_issue" do
    test "adds the issue to a campaign" do
      campaign = insert!(:campaign)
      
      assert {:ok, %Issue{campaign: campaign}} = Tags.add_issue(campaign, "new")
      assert Tags.list_issues() == ["new"]
    end
  end
end
