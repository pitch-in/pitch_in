defmodule PitchIn.HomepageControllerTest do
  use PitchIn.Web.ConnCase

  alias PitchIn.Users.User
  alias PitchIn.Referrals.Referral

  test "index", %{conn: conn} do
    conn = login(conn)
    conn = get conn, "/referrals"
    assert html_response(conn, 200) =~ "My Referrals"
  end

  test "new", %{conn: conn} do
    conn = login(conn)
    conn = get conn, "/referrals/new"
    assert html_response(conn, 200) =~ "Refer a colleague"
  end

  describe "create" do
    test "sends an email", %{conn: conn} do
      conn = login(conn)
      user = conn.assigns.current_user

      email = "test@example.com"
      referrer_id = user.id

      conn = post conn, "/referrals", %{"referral" => %{"email" => email}}

      assert_received {
        :referral_email, 
        _conn,
        %Referral{email: ^email},
        %User{id: ^referrer_id}
      }

      assert redirected_to(conn) == referral_path(conn, :index)
    end
  end
end

