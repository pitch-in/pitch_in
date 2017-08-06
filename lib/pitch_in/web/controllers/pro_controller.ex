defmodule PitchIn.Web.ProController do
  use PitchIn.Web, :controller
  use PitchIn.Web.Auth, protect: :all, pass_user: true
  plug :verify_user when action in [:show, :update]

  alias PitchIn.Users.User
  alias PitchIn.Users.Pro
  alias PitchIn.Web.ErrorView

  def show(conn, %{"id" => _id}, user) do
    pro = get_pro(user)

    changeset = Pro.changeset(pro)
    render(conn, "show.html", user: user, pro: pro, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "pro" => pro_params}, user) do
    pro = get_pro(user)
    changeset = Pro.changeset(pro, pro_params)

    case Repo.update(changeset) do
      {:ok, pro} ->
        complete_user(user)

        conn
        |> put_flash(:success, "Pro updated successfully.")
        |> redirect(to: pro_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "show.html", user: user, pro: pro, changeset: changeset)
    end
  end

  defp get_pro(user) do
    user = user |> Repo.preload(:pro)

    pro =
    if user.pro do
      user.pro
    else
      user |> build_assoc(:pro)
    end
  end

  def verify_user(conn, _opts) do
    {param_id, _} = Integer.parse(conn.params["id"])

    if param_id == conn.assigns.current_user.id do
      conn
    else
      conn
      |> put_status(404)
      |> render(ErrorView, "404.html", layout: false)
      |> halt
    end
  end

  defp complete_user(user) do
    unless user.is_complete do
      changeset = User.complete_changeset(user)
      Repo.update!(changeset)
    end
  end
end
