defmodule PitchIn.ProControllerTest do
  use PitchIn.ConnCase

  alias PitchIn.Pro
  @valid_attrs %{address_city: "some content", address_state: "some content", address_street: "some content", address_unit: "some content", address_zip: "some content", experience_starts_at: %{day: 17, month: 4, year: 2010}, linkedin_url: "some content", phone: "some content", profession: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, pro_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing pros"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, pro_path(conn, :new)
    assert html_response(conn, 200) =~ "New pro"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, pro_path(conn, :create), pro: @valid_attrs
    assert redirected_to(conn) == pro_path(conn, :index)
    assert Repo.get_by(Pro, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, pro_path(conn, :create), pro: @invalid_attrs
    assert html_response(conn, 200) =~ "New pro"
  end

  test "shows chosen resource", %{conn: conn} do
    pro = Repo.insert! %Pro{}
    conn = get conn, pro_path(conn, :show, pro)
    assert html_response(conn, 200) =~ "Show pro"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, pro_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    pro = Repo.insert! %Pro{}
    conn = get conn, pro_path(conn, :edit, pro)
    assert html_response(conn, 200) =~ "Edit pro"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    pro = Repo.insert! %Pro{}
    conn = put conn, pro_path(conn, :update, pro), pro: @valid_attrs
    assert redirected_to(conn) == pro_path(conn, :show, pro)
    assert Repo.get_by(Pro, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    pro = Repo.insert! %Pro{}
    conn = put conn, pro_path(conn, :update, pro), pro: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit pro"
  end

  test "deletes chosen resource", %{conn: conn} do
    pro = Repo.insert! %Pro{}
    conn = delete conn, pro_path(conn, :delete, pro)
    assert redirected_to(conn) == pro_path(conn, :index)
    refute Repo.get(Pro, pro.id)
  end
end
