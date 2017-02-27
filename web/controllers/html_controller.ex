defmodule PitchIn.HtmlController do
  use PitchIn.Web, :controller

  def privacy_policy(conn, _) do
    render(conn, "privacy_policy.html")
  end
end
