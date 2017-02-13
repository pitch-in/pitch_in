defmodule PitchIn.SessionController do
  use PitchIn.Web, :controller
  alias PitchIn.Auth

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.login_by_identity(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:success, "Welcome back!")
        |> redirect(to: ask_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:alert, "Invalid username/password combination.")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout
    |> redirect(to: ask_path(conn, :index))
  end
end
