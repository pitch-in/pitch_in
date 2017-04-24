defmodule PitchIn.Web.SearchAlertController do
  use PitchIn.Web, :controller
  use PitchIn.Web.Auth, protect: :all, pass_user: true

  alias PitchIn.Web.SearchAlert

  def delete(conn, %{"id" => id}, user) do
    alert = Repo.one(
      from s in SearchAlert,
      where: s.user_id == ^user.id,
      where: s.id == ^id
    )

    Repo.delete!(alert)

    conn
    |> put_flash(:success, "Alert deleted successfully.")
    |> redirect(to: user_path(conn, :edit, user))
  end
end
