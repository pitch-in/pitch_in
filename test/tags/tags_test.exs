defmodule PitchIn.Tags.TagsTest do
  use PitchIn.DataCase

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue

  def build(:issue) do
    %Issue{issue: "testing"}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    Repo.insert! build(factory_name, attributes)
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
