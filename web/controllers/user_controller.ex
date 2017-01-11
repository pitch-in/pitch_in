defmodule PitchIn.UserController do
  use PitchIn.Web, :controller
  alias PitchIn.User

  use PitchIn.Auth, protect: [:show, :edit, :update, :delete]
  plug :verify_user when action in [:show, :edit, :update, :delete]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> PitchIn.Auth.login(user)
        |> put_flash(:primary, "User created successfully.")
        |> redirect(to: user_path(conn, :edit, user))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
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
