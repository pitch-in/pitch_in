defmodule PitchIn.Web.HomepageController do
  use PitchIn.Web, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: search_path(conn, :index))
    else
      render conn, "index.html"
    end
  end
end
