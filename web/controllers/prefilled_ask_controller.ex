defmodule PitchIn.PrefilledAskController do
  use PitchIn.Web, :controller

  alias PitchIn.Ask
  alias PitchIn.Campaign

  use PitchIn.Auth, protect: :all
  plug :check_campaign_staff
  plug :verify_campaign_staff

  def index(conn, %{"campaign_id" => campaign_id}) do
    campaign = get_campaign(campaign_id)

    render(conn, "campaign_index.html", campaign: campaign, active_asks: active_asks, archived_asks: archived_asks)
  end
  
  defp get_campaign(id) do
    Repo.get!(Campaign, id)
    |> Repo.preload(:asks)
  end
end
