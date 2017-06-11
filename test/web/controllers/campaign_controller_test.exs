defmodule PitchIn.CampaignControllerTest do
  use PitchIn.Web.ConnCase

  alias PitchIn.Campaign
  @valid_attrs %{candidate_name: "some content", candidate_profession: "some content", current_party: 42, district: "some content", election_date: %{day: 17, month: 4, year: 2010}, facebook_url: "some content", is_partisan: true, long_pitch: "some content", measure_name: "some content", measure_position: "some content", name: "some content", percent_dem: 42, short_pitch: "some content", state: "some content", twitter_url: "some content", type: 42, website_url: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, campaign_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing campaigns"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, campaign_path(conn, :new)
    assert html_response(conn, 200) =~ "New campaign"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, campaign_path(conn, :create), campaign: @valid_attrs
    assert redirected_to(conn) == campaign_path(conn, :index)
    assert Repo.get_by(Campaign, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, campaign_path(conn, :create), campaign: @invalid_attrs
    assert html_response(conn, 200) =~ "New campaign"
  end

  test "shows chosen resource", %{conn: conn} do
    campaign = Repo.insert! %Campaign{}
    conn = get conn, campaign_path(conn, :show, campaign)
    assert html_response(conn, 200) =~ "Show campaign"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, campaign_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    campaign = Repo.insert! %Campaign{}
    conn = get conn, campaign_path(conn, :edit, campaign)
    assert html_response(conn, 200) =~ "Edit campaign"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    campaign = Repo.insert! %Campaign{}
    conn = put conn, campaign_path(conn, :update, campaign), campaign: @valid_attrs
    assert redirected_to(conn) == campaign_path(conn, :show, campaign)
    assert Repo.get_by(Campaign, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    campaign = Repo.insert! %Campaign{}
    conn = put conn, campaign_path(conn, :update, campaign), campaign: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit campaign"
  end

  test "deletes chosen resource", %{conn: conn} do
    campaign = Repo.insert! %Campaign{}
    conn = delete conn, campaign_path(conn, :delete, campaign)
    assert redirected_to(conn) == campaign_path(conn, :index)
    refute Repo.get(Campaign, campaign.id)
  end
end
