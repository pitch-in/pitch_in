defmodule PitchIn.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  defmacro __using__(opts) do
    
    methods = opts[:protect]
    guard =
      case methods do
        nil ->
          false
        :all ->
          true
        _ ->
          quote do
            var!(action) in unquote(methods)
          end
      end

    action =
      if opts[:pass_user] do
        quote do
          def action(conn, _) do
            apply(
              __MODULE__,
              action_name(conn),
              [conn, conn.params, conn.assigns.current_user]
            )
          end
        end
      end

    quote do
      import PitchIn.Auth, only: [authenticate: 2]

      plug :authenticate when unquote(guard)

      unquote(action)
    end
  end

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
  Log the user out, destroying their session.
  """
  def logout(conn) do
    configure_session(conn, drop: true)
  end

  @doc """
  A function Plug to authenticate a route.
  """
  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:alert, "You must log in to view this page.")
      |> Phoenix.Controller.redirect(to: PitchIn.Router.Helpers.session_path(conn, :new))
      |> halt
    end
  end
end
