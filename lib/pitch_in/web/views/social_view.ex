defmodule PitchIn.Web.SocialView do
  use PitchIn.Web, :view

  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Ask

  @spec title(String.t) :: String.t
  def title(type) do
    "Share by #{type}"
  end

  @spec subject(String.t) :: String.t
  def subject(name) do
    "#{name} needs your help!"
  end

  def facebook_link(conn, campaign, ask) do
    link = 
      conn
      |> link_path(campaign, ask)
      |> URI.encode_www_form

    query = URI.encode_query(%{
      display: "popup",
      href: link
    })

    "https://www.facebook.com/dialog/share?#{query}"
  end

  def twitter_link(conn, campaign, ask) do
    link = link_path(conn, campaign, ask)

    query = URI.encode_query(%{
      text: twitter_text(campaign.name),
      url: link
    })

    "https://twitter.com/intent/tweet?#{query}"
  end

  def email_link(conn, campaign, ask) do
    link = link_path(conn, campaign, ask)

    query = URI.encode_query(%{
      subject: subject(campaign.name),
      body: email_body(conn, campaign, ask)
    })

    "mailto:?#{query}"
  end

  defp link_path(conn, campaign, nil) do
    base_url(
      conn,
      campaign_path(conn, :show, campaign)
    )
  end
  defp link_path(conn, campaign, ask) do
    base_url(
      conn,
      campaign_ask_path(conn, :show, campaign, ask)
    )
  end

  defp twitter_text(name) do
    "I saw #{name} on @Pitch_In_US, and they need your help!"
  end

  defp email_body(conn, campaign, ask) do
    "I saw #{campaign.name} on Pitch In, and thought you might want to help out! You can find out more at #{link_path(conn, campaign, ask)}"
  end
end

