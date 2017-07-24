defmodule PitchIn.Web.ReferralController do
  use PitchIn.Web, :controller

  use PitchIn.Web.Auth, protect: :all, pass_user: true

  alias PitchIn.Email
  alias PitchIn.Mailer

  alias PitchIn.Web.User
  alias PitchIn.Referrals
  alias PitchIn.Referrals.Referral

  @email Application.get_env(:pitch_in, :email, Email)
  @mailer Application.get_env(:pitch_in, :mailer, Mailer)

  def index(conn, _params, user) do
    referrals = Referrals.list_referrals(user)
    render(conn, "index.html", conn: conn, referrals: referrals)
  end

  def new(conn, _params, user) do
    changeset = Referrals.referral_changeset()
    render(conn, "new.html", user: user, changeset: changeset)
  end

  def create(conn, %{"referral" => %{"email" => email}}, user) do
    with {:ok, referral} <- Referrals.add_referral(user, email),
         _ <- email_referral(conn, referral, user)
    do
      conn
      |> put_flash(:success, "Thanks for the referral!")
      |> redirect(to: referral_path(conn, :index))
    else
      {:error, changeset} ->
        render(conn, "new.html", user: user, changeset: changeset)
    end
  end

  defp email_referral(conn, %Referral{} = referral, %User{} = user) do
    conn
    |> @email.referral_email(referral, user)
    |> @mailer.deliver_later
  end
end
