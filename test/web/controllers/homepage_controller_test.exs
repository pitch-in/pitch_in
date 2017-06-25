defmodule PitchIn.HomepageControllerTest do
  use PitchIn.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "We are a meeting place"
  end
end
