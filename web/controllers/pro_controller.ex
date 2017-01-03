defmodule PitchIn.ProController do
  use PitchIn.Web, :controller

  alias PitchIn.Pro

  def index(conn, _params) do
    pros = Repo.all(Pro)
    render(conn, "index.html", pros: pros)
  end

  def new(conn, _params) do
    changeset = Pro.changeset(%Pro{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pro" => pro_params}) do
    changeset = Pro.changeset(%Pro{}, pro_params)

    case Repo.insert(changeset) do
      {:ok, _pro} ->
        conn
        |> put_flash(:info, "Pro created successfully.")
        |> redirect(to: pro_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

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
        |> put_flash(:info, "Pro updated successfully.")
        |> redirect(to: pro_path(conn, :show, pro))
      {:error, changeset} ->
        render(conn, "edit.html", pro: pro, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pro = Repo.get!(Pro, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(pro)

    conn
    |> put_flash(:info, "Pro deleted successfully.")
    |> redirect(to: pro_path(conn, :index))
  end
end
