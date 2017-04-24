defmodule PitchIn.Web.PageController do
  use PitchIn.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
