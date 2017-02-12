defmodule PitchIn.EmailView do
  use PitchIn.Web, :view

  def full_domain(%Plug.Conn{scheme: scheme, host: host, port: port}) do
    url = "#{scheme}://#{host}"
    if port do
      url <> port
    else
      url
    end
  end
end
