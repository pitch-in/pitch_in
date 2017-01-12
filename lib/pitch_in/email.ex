defmodule PitchIn.Email do
  use Bamboo.Phoenix, view: PitchIn.EmailView

  @pitch_in_email Application.get_env(:pitch_in, PitchIn.Email)[:from_email]

  def welcome_email(email_address) do
    email_address
    |> base_email
    |> subject("Thanks for pitching in!")
    |> render("welcome.html")
  end

  def test_email(email_address) do
    email_address
    |> base_email
    |> subject("Just a test")
    |> render("test.html")
  end

  defp base_email(email_address) do
    new_email
    |> to(email_address)
    |> from(@pitch_in_email)
    |> put_html_layout({PitchIn.LayoutView, "email.html"})
  end
end
