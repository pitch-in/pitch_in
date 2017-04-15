require IEx

defmodule PitchIn.EmailView do
  use PitchIn.Web, :view

  def full_password_reset_path(conn, user) do
    base_url(conn) <> forgot_password_path(conn, :index, email: user.email, token: user.reset_token)
  end
end
