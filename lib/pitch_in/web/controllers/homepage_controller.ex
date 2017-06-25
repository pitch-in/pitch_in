defmodule PitchIn.Web.HomepageController do
  use PitchIn.Web, :controller

  alias PitchIn.Politics

  def index(conn, _params) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: search_path(conn, :index))
    else
      render conn, "index.html", search_changeset: Politics.search_changeset()
    end
  end
end
