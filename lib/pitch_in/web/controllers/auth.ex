defmodule PitchIn.Web.Auth do
  @moduledoc """
  Holds the auth pipeline, and auth functions
  """

  alias PitchIn.Repo
  alias PitchIn.Users.User
  alias PitchIn.Campaigns.CampaignStaff
  alias PitchIn.Web.ErrorView
  import Ecto
  import Ecto.Query
  import Phoenix.Controller, only: [put_flash: 3, render: 4, redirect: 2]

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
      import PitchIn.Web.Auth, only: [
        authenticate: 2,
        check_campaign_staff: 2,
        verify_campaign_staff: 2
      ]

      plug :authenticate when unquote(guard)

      unquote(action)
    end
  end

  def init(opts) do
    # Raises if no repo is passed in.
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    if conn.assigns[:current_user] do
      conn
    else
      user_id = get_session(conn, :user_id)
      user = user_id && repo.get(User, user_id)

      assign(conn, :current_user, user)
    end
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
    user = repo.get_by(User, email: email)

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
      deep_link_redirect(conn)
    end
  end

  @doc """
  A function Plug to add is_staff to assigns.
  """
  def check_campaign_staff(conn, opts) do
    id_key = opts[:id] || "campaign_id"
    user = conn.assigns.current_user

    cond do
      !conn.params[id_key] || !user ->
        assign(conn, :is_staff, false)
      user.is_admin ->
        assign(conn, :is_staff, true)
      true ->
        user_id = user.id
        {campaign_id, _} = Integer.parse(conn.params[id_key])

        staff_query =
          from s in CampaignStaff,
          select: count(s.user_id),
          where: s.campaign_id == ^campaign_id,
          where: s.user_id == ^user_id

        count = Repo.one(staff_query)

        if count > 0 do
          assign(conn, :is_staff, true)
        else
          assign(conn, :is_staff, false)
        end
    end
  end

  @doc """
  A function Plug that fails if the user is not staff.
  """
  def verify_campaign_staff(conn, _opts) do
    is_staff = conn.assigns.is_staff

    if is_staff do
      conn
    else
      conn
      |> put_status(404)
      |> render(ErrorView, "404.html", layout: false)
      |> halt
    end
  end

  def verify_admin(conn, _opts) do
    user = conn.assigns.current_user
    if user && user.is_admin do
      conn
    else
      conn
      |> put_status(404)
      |> render(ErrorView, "404.html", layout: false)
      |> halt
    end
  end

  def deep_link_redirect(conn, path \\ nil) do
    path = path || conn.request_path

    conn
    |> store_deep_link_path(path)
    |> put_flash(:alert, "You must log in to view this page.")
    |> redirect(to: PitchIn.Web.Router.Helpers.session_path(conn, :new))
    |> halt
  end

  def store_deep_link_path(conn, path) do
    conn
    |> put_session(:deep_link_path, path)
  end

  def get_deep_link_path(conn) do
    conn
    |> get_session(:deep_link_path)
  end

  def clear_deep_link_path(conn) do
    conn
    |> delete_session(:deep_link_path)
  end
end
