defmodule PitchIn.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def init(opts) do
    # Raises if no repo is passed in.
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(PitchIn.User, user_id)

    assign(conn, :current_user, user)
  end

  @doc """
  Log a user object in.
  """
  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  @doc """
  Log in from the login screen
  """
  def login_by_identity(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(PitchIn.User, email: email)

    cond do
      !user ->
        dummy_checkpw()
        {:error, :not_found, conn}
      checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      true ->
        {:error, :unauthorized, conn}
    end
  end

  @doc """
  A function Plug to authenticate a route.
  """
  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to view this page.")
      |> redirect(to: "")
    end
  end
end
