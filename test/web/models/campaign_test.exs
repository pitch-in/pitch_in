defmodule PitchIn.CampaignTest do
  use PitchIn.ModelCase

  alias PitchIn.Web.Campaign

  @valid_attrs %{candidate_name: "some content", candidate_profession: "some content", current_party: 42, district: "some content", election_date: %{day: 17, month: 4, year: 2010}, facebook_url: "some content", is_partisan: true, long_pitch: "some content", measure_name: "some content", measure_position: "some content", name: "some content", percent_dem: 42, short_pitch: "some content", state: "some content", twitter_url: "some content", type: 42, website_url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @invalid_attrs)
    refute changeset.valid?
  end
end
