defmodule PitchIn.Admin.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.CampaignView

  def index(conn, _params) do
    campaigns = Repo.all(from c in Campaign, order_by: [desc: :inserted_at])

    render(conn, "index.html", campaigns: campaigns)
  end
end
