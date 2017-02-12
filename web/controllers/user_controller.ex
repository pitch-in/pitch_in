defmodule PitchIn.UserController do
  use PitchIn.Web, :controller
  alias PitchIn.User
  alias PitchIn.Pro
  alias PitchIn.Campaign
  alias PitchIn.Email
  alias PitchIn.Mailer

  use PitchIn.Auth, protect: [:show, :edit, :update, :delete]
  plug :verify_user when action in [:show, :edit, :update, :delete]

  def new(conn, %{"staff" => _}) do
    changeset = User.changeset(%User{})
    render(conn, "new_staff.html", changeset: changeset)
  end

  def new(conn, params) do
    changeset = 
      %User{}
      |> User.changeset
      |> Ecto.Changeset.put_assoc(:pro, %Pro{})
    render(conn, "new_activist.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params, "staff" => _}) do
    changeset = 
      User.staff_registration_changeset(
        %User{pro: %Pro{}, campaigns: [%Campaign{}]},
        user_params
      )

    case Repo.insert(changeset) do
      {:ok, user} ->
        Email.staff_welcome_email(user.email, conn, user)
        |> Mailer.deliver_later

        conn
        |> PitchIn.Auth.login(user)
        |> put_flash(:primary, """
          Welcome to Pitch In! You can now create a campaign, and then start
          posting what you need to get your campaign going!
        """)
        |> redirect(to: campaign_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new_staff.html", changeset: changeset)
    end
  end

  def create(conn, %{"user" => user_params}) do
    changeset = 
      %User{}
      |> User.activist_registration_changeset(user_params)
      |> IO.inspect

    case Repo.insert(changeset) do
      {:ok, user} ->
        Email.activist_welcome_email(user.email, conn, user)
        |> Mailer.deliver_later

        conn
        |> PitchIn.Auth.login(user)
        |> put_flash(:success, """
          Welcome to Pitch In! Feel free to check out what help campaigns are looking
          for, or finish filling out your profile!
        """)
        |> redirect(to: ask_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new_activist.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = get_pro_user(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = get_pro_user(id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = get_pro_user(id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:primary, "User updated successfully.")
        |> redirect(to: user_path(conn, :edit, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = get_pro_user(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:primary, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
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
      |> render(PitchIn.ErrorView, "404.html")
      |> halt
    end
  end
end
