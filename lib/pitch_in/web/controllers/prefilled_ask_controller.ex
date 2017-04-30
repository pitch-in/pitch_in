defmodule PitchIn.Web.PrefilledAskController do
  use PitchIn.Web, :controller

  alias PitchIn.Web.Ask
  alias PitchIn.Web.Campaign
  alias PitchIn.Web.PrefilledAsk

  use PitchIn.Web.Auth, protect: :all
  plug :check_campaign_staff
  plug :verify_campaign_staff

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    conn
    |> render("index.html", campaign: campaign, prefilled_asks: PrefilledAsk.asks_to_display)
  end

  def create(conn, %{"campaign_id" => campaign_id, "prefilled_asks" => prefilled_asks}) do
    campaign = get_campaign(campaign_id)

    ids =
      prefilled_asks
      |> Enum.filter_map(
        fn {_id, value} -> value == "true" end,
        fn {id, _value} -> id end
      )
    asks = PrefilledAsk.asks_to_create(ids, campaign)

    insert_asks(asks)

    conn
    |> put_flash(:success, "Great! You're set up with your first needs.")
    |> redirect(to: campaign_path(conn, :interstitial, campaign))

  end
  
  defp get_campaign(id) do
    Campaign
    |> Repo.get!(id)
    |> Repo.preload(:asks)
  end

  defp insert_asks(asks) do
    for ask <- asks, do: Repo.insert(ask)
  end
end
