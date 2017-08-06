defmodule PitchIn.Mail.Email do
  @moduledoc """
  Defines emails the app can send.
  """
  use Bamboo.Phoenix, view: PitchIn.Web.EmailView
  import Bamboo.SendgridHelper

  alias PitchIn.Users.User
  alias PitchIn.Web.ContactUs
  alias PitchIn.Referrals.Referral

  @pitch_in_email Application.get_env(:pitch_in, PitchIn.Mail.Email)[:from_email]
  @contact_us_email Application.get_env(:pitch_in, PitchIn.Mail.Email)[:contact_us_email]
  @template_id Application.get_env(:pitch_in, PitchIn.Mail.Email)[:basic_template_id]

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

  def accepted_answer_email(email_address, conn, campaign, answer) do
    email_address
    |> base_email
    |> subject("#{campaign.name} wants to work with you!")
    |> render("accepted_answer.html", conn: conn, campaign: campaign, answer: answer)
  end

  def referral_email(conn, %Referral{} = referral, %User{} = referrer) do
    referral.email
    |> base_email
    |> subject("#{referrer.name} invited you to Pitch In!")
    |> render("referral.html", conn: conn, referral: referral, referrer: referrer)
  end

  def contact_us_email(_conn, %ContactUs{
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
    |> with_template(@template_id)
  end
end
