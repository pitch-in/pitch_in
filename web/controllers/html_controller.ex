defmodule PitchIn.HtmlController do
  use PitchIn.Web, :controller

  def privacy_policy(conn, _) do
    render(conn, "privacy_policy.html")
  end

  def about_us(conn, _) do
    render(conn, "about_us.html")
  end

  def donate_thanks(conn, _) do
    render(conn, "donate_thanks.html")
  end

  def faq(conn, _) do
    render(conn, "faq.html")
  end
end
