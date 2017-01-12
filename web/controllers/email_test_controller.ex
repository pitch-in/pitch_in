defmodule PitchIn.EmailTestController do
  use PitchIn.Web, :controller

  alias PitchIn.Email
  alias PitchIn.Mailer

  def test(conn, _) do
    email = Application.get_env(:pitch_in, PitchIn.Email)[:test_email]
    Email.test_email(email) |> Mailer.deliver_now

    text conn, "Email sent!"
  end
end
