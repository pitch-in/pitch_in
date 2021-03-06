defmodule PitchIn.Web.ContactUsController do
  use PitchIn.Web, :controller
  use PitchIn.Web.Auth, pass_user: true

  alias PitchIn.Mail.Email
  alias PitchIn.Mail.Mailer
  alias PitchIn.Web.ContactUs

  def index(conn, _, user) do
    changeset = ContactUs.changeset(%ContactUs{
      email: if(user, do: user.email),
      name: if(user, do: user.name),
    })
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"contact_us" => contact_us_params}, _user) do
    changeset = ContactUs.changeset(%ContactUs{}, contact_us_params)

    if changeset.valid? do
      contact_us_data = Ecto.Changeset.apply_changes(changeset)

      conn
      |> Email.contact_us_email(contact_us_data)
      |> Mailer.deliver_later

      conn = 
        conn
        |> put_flash(:success, "Thanks for your comments - we'll get back to you soon!")

      if contact_us_data.from_page == "home" do
        conn |> redirect(to: homepage_path(conn, :index))
      else
        conn |> redirect(to: contact_us_path(conn, :index))
      end
    else
      render(conn, "index.html", changeset: changeset)
    end
  end
end
