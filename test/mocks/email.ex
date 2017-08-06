defmodule PitchIn.Test.Mocks.Mail.Email do
  alias PitchIn.Users.User
  alias PitchIn.Web.ContactUs
  alias PitchIn.Referrals.Referral

  def staff_welcome_email(email_address, conn, user, campaign) do
    send self(), {:staff_welcome_email, email_address, conn, user, campaign}
  end

  def volunteer_welcome_email(email_address, conn, user) do
    send self(), {:volunteer_welcome_email, email_address, conn, user}
  end

  def password_reset_token_email(conn, user) do
    send self(), {:password_reset_token_email, conn, user}
  end

  def password_reset_success_email(conn, user) do
    send self(), {:password_reset_success_email, conn, user}
  end

  def user_answer_email(email_address, conn, campaign, ask, answer) do
    send self(), {:user_answer_email, email_address, conn, campaign, ask, answer}
  end

  def campaign_answer_email(email_address, conn, campaign, ask, answer) do
    send self(), {:campaign_answer_email, email_address, conn, campaign, ask, answer}
  end

  def accepted_answer_email(email_address, conn, campaign, answer) do
    send self(), {:accepted_answer_email, email_address, conn, campaign, answer}
  end

  def referral_email(conn, %Referral{} = referral, %User{} = referrer) do
    send self(), {:referral_email, conn, referral, referrer}
  end

  def contact_us_email(conn, %ContactUs{} = contact_us) do
    send self(), {:contact_us_email, conn, %ContactUs{} = contact_us, contact_us}
  end

  def admin_new_campaign_email(conn, campaign) do
    send self(), {:admin_new_campaign_email, conn, campaign}
  end

  def deliver_later(email) do
    send self(), {:deliver_later, email}
  end
end

