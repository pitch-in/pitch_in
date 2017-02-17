defmodule PitchIn.ContactUsController do
  use PitchIn.Web, :controller
  use PitchIn.Auth, pass_user: true

  alias PitchIn.Email
  alias PitchIn.Mailer
  alias PitchIn.ContactUs

  def index(conn, _, user) do
    changeset = ContactUs.changeset(%ContactUs{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"contact_us" => message_params}, user) do
    changeset = ContactUs.changeset(%ContactUs{}, message_params)

    if changeset.valid? do
      Email.contact_us_email(conn, user, Ecto.Changeset.apply_changes(changeset)) |> Mailer.deliver_later

      conn
      |> put_flash(:success, "Thanks for your comments - we'll get back to you soon!")
      |> redirect(to: contact_us_path(conn, :index))
    else
      render(conn, "index.html", changeset: changeset)
    end
  end
end
