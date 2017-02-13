defmodule PitchIn.Email do
  use Bamboo.Phoenix, view: PitchIn.EmailView

  @pitch_in_email Application.get_env(:pitch_in, PitchIn.Email)[:from_email]

  def staff_welcome_email(email_address, conn, user, campaign) do
    email_address
    |> base_email
    |> subject("Thanks for signing up to pitch in!")
    |> render("staff_welcome.html", conn: conn, user: user, campaign: campaign)
  end

  def activist_welcome_email(email_address, conn, user) do
    email_address
    |> base_email
    |> subject("Thanks for signing up with pitch in!")
    |> render("activist_welcome.html", conn: conn, user: user)
  end

  def user_answer_email(email_address, conn, campaign, ask, answer) do
    email_address
    |> base_email
    |> subject("Thanks for pitching in!")
    |> render("user_answer.html", conn: conn, campaign: campaign, ask: ask, answer: answer)
  end

  def campaign_answer_email(email_address, conn, campaign, ask, answer) do
    email_address
    |> base_email
    |> subject("You've received a new answer!")
    |> render("campaign_answer.html", conn: conn, campaign: campaign, ask: ask, answer: answer)
  end

  def test_email(email_address, conn) do
    email_address
    |> base_email
    |> subject("Just a test")
    |> render("test.html", conn: conn)
  end

  defp base_email(email_address) do
    new_email()
    |> to(email_address)
    |> from(@pitch_in_email)
    |> put_html_layout({PitchIn.LayoutView, "email.html"})
  end
end
