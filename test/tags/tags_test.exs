defmodule PitchIn.Tags.TagsTest do
  use PitchIn.DataCase

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue
  alias PitchIn.Web.User
  alias PitchIn.Web.Campaign

  def build(:issue) do
    %Issue{issue: "testing"}
  end

  def build(:campaign) do
    %Campaign{}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    Repo.insert! build(factory_name, attributes)
  end

  describe "list_issues" do
    setup do
      insert!(:issue, issue: "other")
      insert!(:issue, issue: "testing")
      insert!(:issue, issue: "testing")
    end

    test "list_issues/0 returns all issues" do
      insert!(:issue, issue: "other")
      insert!(:issue, issue: "testing")
      insert!(:issue, issue: "testing")

      assert Tags.list_issues() == ["testing", "other"]
    end

    test "list_issues/1 returns filtered issues" do
      insert!(:issue, issue: "other")
      insert!(:issue, issue: "testing")
      insert!(:issue, issue: "testing")

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
