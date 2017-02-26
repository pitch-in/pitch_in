defmodule PitchIn.RobotsController do
  use PitchIn.Web, :controller

  def show(conn, _) do
    case Application.get_env(:pitch_in, :server_env) do
      "prod" ->
        render(conn, "robots.txt", layout: false)
      _ ->
        render(conn, "robots-staging.txt", layout: false)
    end
  end
end
