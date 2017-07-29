defmodule PitchIn.Web.ForgotPasswordControllerTest do
  use PitchIn.Web.ConnCase
  
  alias PitchIn.Users.User

  test "renders form for forgot password ", %{conn: conn} do
    conn = get conn, forgot_password_path(conn, :index)
    assert html_response(conn, 200) =~ "Forgot your password?"
  end

  test "creates new forgot_password token for a real user", %{conn: conn} do
    user = insert!(:user)

    refute user.reset_digest

    conn = post conn, forgot_password_path(conn, :create, %{forgot_password: %{email: user.email}})

    user = Repo.get(User, user.id)
    assert user.reset_digest

    user_id = user.id
    assert_received {
      :password_reset_token_email, 
      _conn,
      %User{id: ^user_id}
    }

    assert redirected_to(conn) == forgot_password_path(conn, :email_sent, email: user.email)
  end

  test "does not create a new forgot_password token for an unknown user", %{conn: conn} do
    user = insert!(:user)

    refute user.reset_digest

    conn = post conn, forgot_password_path(conn, :create, %{forgot_password: %{email: "bad@email.com"}})

    user = Repo.get(User, user.id)
    refute user.reset_digest


    refute_received { :password_reset_token_email, _, _ }

    assert redirected_to(conn) == forgot_password_path(conn, :email_sent, email: "bad@email.com")
  end

  test "fails with an unknown token", %{conn: conn} do
    conn = get conn, forgot_password_path(conn, :index, %{email: "bad@example.com", token: "abc"})
    assert html_response(conn, 200) =~ "Password reset link not valid"
  end

  test "allows edits with a known token", %{conn: conn} do
    token = "abc"
    user = :user |> build() |> with_forgot_password(token)
    user = %User{user | reset_time: Timex.now}
    Repo.insert!(user)
    
    conn = get conn, forgot_password_path(conn, :index, %{email: user.email, token: token})
    assert html_response(conn, 200) =~ "Reset your password for"
  end

  test "redirects when the user is already logged in", %{conn: conn} do
    conn = login(conn)
    user = conn.assigns.current_user

    conn = get conn, forgot_password_path(conn, :index, %{email: user.email, token: "abc"})
    assert redirected_to(conn) == homepage_path(conn, :index)
  end
end
