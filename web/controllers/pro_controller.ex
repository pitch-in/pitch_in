defmodule PitchIn.ProController do
  use PitchIn.Web, :controller

  alias PitchIn.Pro

  def show(conn, %{"id" => id}) do
    pro = Repo.get!(Pro, id)
    render(conn, "show.html", pro: pro)
  end

  def edit(conn, %{"id" => id}) do
    pro = Repo.get!(Pro, id)
    changeset = Pro.changeset(pro)
    render(conn, "edit.html", pro: pro, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pro" => pro_params}) do
    pro = Repo.get!(Pro, id)
    changeset = Pro.changeset(pro, pro_params)

    case Repo.update(changeset) do
      {:ok, pro} ->
        conn
        |> put_flash(:primary, "Pro updated successfully.")
        |> redirect(to: pro_path(conn, :show, pro))
      {:error, changeset} ->
        render(conn, "edit.html", pro: pro, changeset: changeset)
    end
  end
end
