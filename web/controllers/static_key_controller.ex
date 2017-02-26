defmodule PitchIn.StaticKeyController do
  use PitchIn.Web, :controller

  def robots(conn, _) do
    case Application.get_env(:pitch_in, :server_env) do
      "prod" ->
        render(conn, "robots.txt", layout: false)
      _ ->
        render(conn, "robots-staging.txt", layout: false)
    end
  end

  def cert(conn, %{"cert_id" => cert_id}) do
    cert_key = Application.get_env(:pitch_in, :cert)

    text conn, "#{cert_id}.#{cert_key}"
  end
end
