defmodule PitchIn.Web.IssueControllerTest do
  use PitchIn.Web.ConnCase

  alias PitchIn.Tags
  alias PitchIn.Tags.Issue

  @create_attrs %{value: "some value"}
  @update_attrs %{value: "some updated value"}
  @invalid_attrs %{value: nil}

  def fixture(:issue) do
    {:ok, issue} = Tags.create_issue(@create_attrs)
    issue
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, issue_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates issue and renders issue when data is valid", %{conn: conn} do
    conn = post conn, issue_path(conn, :create), issue: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, issue_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "value" => "some value"}
  end

  test "does not create issue and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, issue_path(conn, :create), issue: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen issue and renders issue when data is valid", %{conn: conn} do
    %Issue{id: id} = issue = fixture(:issue)
    conn = put conn, issue_path(conn, :update, issue), issue: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, issue_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "value" => "some updated value"}
  end

  test "does not update chosen issue and renders errors when data is invalid", %{conn: conn} do
    issue = fixture(:issue)
    conn = put conn, issue_path(conn, :update, issue), issue: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen issue", %{conn: conn} do
    issue = fixture(:issue)
    conn = delete conn, issue_path(conn, :delete, issue)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, issue_path(conn, :show, issue)
    end
  end
end
