defmodule PitchIn.UserController do
  use PitchIn.NextSteps
  use PitchIn.Web, :controller
  alias PitchIn.User
  alias PitchIn.Pro
  alias PitchIn.Campaign
  alias PitchIn.Email
  alias PitchIn.Mailer
  alias PitchIn.Auth

  use PitchIn.Auth, protect: [:show, :edit, :update]
  plug :verify_user when action in [:show, :edit, :update]

  def new(conn, %{"staff" => _}) do
    changeset = User.changeset(%User{campaigns: [%Campaign{}]})
    render(conn, "new_staff.html", changeset: changeset)
  end

  def new(conn, params) do
    changeset = 
      %User{}
      |> User.changeset
      |> Ecto.Changeset.put_assoc(:pro, %Pro{})
    render(conn, "new_volunteer.html", changeset: changeset)
  end

  def interstitial(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render(conn, "volunteer_interstitial.html", user: user)
  end

  def create(conn, %{"user" => user_params, "staff" => _}) do
    # Use staff email for campaign as a default.
    user_params = 
      user_params
      |> put_in(["campaigns", "0", "email"], user_params["email"])
      |> put_in(["campaigns", "0", "shown_whats_next"], "false")

    changeset = 
      %User{}
      |> User.staff_registration_changeset(user_params)

    case Repo.insert(changeset) do
      {:ok, %User{campaigns: [campaign]} = user} ->
        Email.staff_welcome_email(user.email, conn, user, campaign)
        |> Mailer.deliver_later

        path = Auth.get_deep_link_path(conn) || campaign_path(conn, :edit, campaign)

        conn
        |> Auth.login(user)
        |> put_flash(:success, """
          Welcome to Pitch In! You can now create a campaign, and then start
          posting what you need to get your campaign going!
        """)
        |> Auth.clear_deep_link_path
        |> redirect(to: path)
      {:error, changeset} ->
        render(conn, "new_staff.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    changeset = 
      %User{}
      |> User.volunteer_registration_changeset(user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        Email.volunteer_welcome_email(user.email, conn, user)
        |> Mailer.deliver_later

        path = Auth.get_deep_link_path(conn) || user_path(conn, :interstitial, user)

        conn
        |> Auth.login(user)
        |> Auth.clear_deep_link_path
        |> redirect(to: path)
      {:error, changeset} ->
        render(conn, "new_volunteer.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = 
      get_pro_user(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user =
      get_pro_user(id)
      |> Repo.preload(:search_alerts)

    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user =
      get_pro_user(id)
      |> Repo.preload(:search_alerts)

    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "User updated successfully.")
        |> redirect(to: user_path(conn, :edit, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  defp get_pro_user(id) do
    Repo.get!(User, id)
    |> Repo.preload(:pro)
  end

  def verify_user(conn, _opts) do
    {param_id, _} = Integer.parse(conn.params["id"])

    if param_id == conn.assigns.current_user.id do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:alert, "You don't have access to that page.")
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html", layout: false)
      |> halt
    end
  end
end
