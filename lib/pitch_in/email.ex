defmodule PitchIn.Email do
  @moduledoc """
  Defines emails the app can send.
  """
  use Bamboo.Phoenix, view: PitchIn.EmailView

  @pitch_in_email Application.get_env(:pitch_in, PitchIn.Email)[:from_email]
  @contact_us_email Application.get_env(:pitch_in, PitchIn.Email)[:contact_us_email]

  def staff_welcome_email(email_address, conn, user, campaign) do
    email_address
    |> base_email
    |> subject("Thanks for signing up to pitch in!")
    |> render("staff_welcome.html", conn: conn, user: user, campaign: campaign)
  end

  def volunteer_welcome_email(email_address, conn, user) do
    email_address
    |> base_email
    |> subject("Thanks for signing up with pitch in!")
    |> render("volunteer_welcome.html", conn: conn, user: user)
  end

  def password_reset_token_email(conn, user) do
    user.email
    |> base_email
    |> subject("Your password reset link")
    |> render("password_reset_token.html", conn: conn, user: user)
  end

  def password_reset_success_email(conn, user) do
    user.email
    |> base_email
    |> subject("Password reset!")
    |> render("password_reset_success.html", conn: conn, user: user)
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

  def contact_us_email(_conn, %PitchIn.ContactUs{
    subject: user_subject,
    body: user_body,
    email: from_email,
    name: from_name
  }) do
    new_email()
    |> to(@contact_us_email)
    |> from({from_name, from_email})
    |> subject("PITCH IN CONTACT US: #{user_subject}")
    |> text_body(user_body)
  end

  def admin_new_campaign_email(conn, campaign) do
    @contact_us_email
    |> base_email
    |> subject("New Campaign!")
    |> render("admin_new_campaign.html", conn: conn, campaign: campaign)
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
    |> from({"Pitch In", @pitch_in_email})
    |> put_html_layout({PitchIn.LayoutView, "email.html"})
  end
end
