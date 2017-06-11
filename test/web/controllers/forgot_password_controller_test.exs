defmodule PitchIn.ForgotPasswordControllerTest do
  use PitchIn.Web.ConnCase
  alias PitchIn.ForgotPassword

  test "renders form for forgot password ", %{conn: conn} do
    conn = get conn, forgot_password_path(conn, :index)
    assert html_response(conn, 200) =~ "Forgot your password?"
  end

  test "creates new forgot_password token for a real user", %{conn: conn} do
    user = build(:user)

    assert length(Repo.all(ForgotPassword)) == 0

    conn = post conn, forgot_password_path(conn, :create, %{forgot_password: %{email: user.email}})

    assert length(Repo.all(ForgotPassword)) == 1

    assert redirected_to(conn) == forgot_password_path(conn, :email_sent)
  end

  test "does not create a new forgot_password token for an unknown user", %{conn: conn} do
    user = build(:user)

    assert length(Repo.all(ForgotPassword)) == 0

    conn = post conn, forgot_password_path(conn, :create, %{forgot_password: %{email: "bad@email.com"}})

    assert length(Repo.all(ForgotPassword)) == 0

    assert redirected_to(conn) == forgot_password_path(conn, :email_sent)
  end

  test "fails with an unknown token", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, forgot_password_path(conn, :show, "abc")
    end
  end

  test "redirects with a known token", %{conn: conn} do
    forgot_password = build(:forgot_password) |> with_user |> Repo.insert!
    token = forgot_password.token
    
    get conn, forgot_password_path(conn, :show, token)
    assert redirected_to(conn) == homepage_path(conn, :index)
  end

  test "redirects when the user is already logged in", %{conn: conn} do
    conn = login(conn)

    get conn, forgot_password_path(conn, :show, "abc")
    assert redirected_to(conn) == homepage_path(conn, :index)
  end
end

