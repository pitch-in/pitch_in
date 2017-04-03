defmodule PitchIn.SessionController do
  use PitchIn.Web, :controller
  alias PitchIn.Auth

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.login_by_identity(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        case Auth.get_deep_link_path(conn) do
          nil -> redirect_to_default(conn)
          deep_link_path ->
            conn
            |> Auth.clear_deep_link_path
            |> redirect_deep(deep_link_path)
        end
      {:error, _reason, conn} ->
        conn
        |> put_flash(:alert, "Invalid username/password combination.")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout
    |> redirect(to: search_path(conn, :index))
  end

  defp redirect_to_default(conn) do
    conn
    |> put_flash(:success, "Welcome back!")
    |> redirect(to: search_path(conn, :index))
  end

  defp redirect_deep(conn, deep_link_path) do
    conn
    |> put_flash(:success, "Welcome back!")
    |> redirect(to: deep_link_path)
  end
end
