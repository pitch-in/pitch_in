defmodule PitchIn.ForgotPasswordController do
  use PitchIn.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias PitchIn.User
  alias PitchIn.Auth
  alias PitchIn.Email
  alias PitchIn.Mailer

  def create(conn, %{"forgot_password" => params}) do
    email = params["email"]
    user = Repo.get_by(User, email: params["email"])

    cond do
      !email ->
        conn
        |> put_flash(:alert, "Please provide an email address.")
        |> render("new.html")
      user ->
        changeset = User.forgot_password_changeset(user)

        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> Email.password_reset_token_email(user)
            |> Mailer.deliver_later
            
            redirect_to_email_sent(conn, email)
          {:error, changeset} ->
            redirect_to_email_sent(conn, email)
        end
      true ->
        dummy_checkpw()
        redirect_to_email_sent(conn, email)
    end
  end

  def index(conn, %{"email" => email, "token" => token} = params) do
    user = Repo.get_by(User, email: params["email"])
    changeset = User.changeset(user)

    cond do
      conn.assigns.current_user ->
        redirect_to_home(conn)
      !valid_token?(conn, user, params) ->
        conn
        |> render("error.html")
      true ->
        conn
        |> render("edit.html", changeset: changeset, token: token)
    end
  end

  def index(conn, _params) do
    render conn, "new.html"
  end

  def update(conn, %{"id" => id, "token" => token, "user" => user_params} = params) do
    user = Repo.get(User, id)
    changeset = User.password_changeset(user, user_params)

    cond do
      !valid_token?(conn, user, params) ->
        conn
        |> render("error.html")
      true ->
        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> Email.password_reset_success_email(user)
            |> Mailer.deliver_later

            conn
            |> put_flash(:success, "Password successfully reset!")
            |> Auth.login(user)
            |> redirect_to_home
          {:error, changeset} ->
            conn
            |> render("show.html", changeset: changeset)
        end
    end
  end

  def email_sent(conn, %{"email" => email}) do
    conn
    |> render("email_sent.html", email: email)
  end

  defp valid_token?(conn, user, %{"token" => token}) do
    user &&
      Timex.diff(Timex.now, user.reset_time, :hours) < 2 &&
      checkpw(token, user.reset_digest)
  end

  defp redirect_to_email_sent(conn, email) do
    conn
    |> redirect(to: forgot_password_path(conn, :email_sent, email: email))
  end

  defp redirect_to_home(conn) do
    conn
    |> redirect(to: search_path(conn, :index))
  end
end

