defmodule PitchIn.ProController do
  use PitchIn.Web, :controller
  use PitchIn.Auth, protect: :all, pass_user: true
  plug :verify_user when action in [:show, :update]

  alias PitchIn.User
  alias PitchIn.Pro

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
        conn
        |> put_flash(:primary, "Pro updated successfully.")
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
      |> Phoenix.Controller.put_flash(:alert, "You don't have access to that user.")
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html")
      |> halt
    end
  end
end
