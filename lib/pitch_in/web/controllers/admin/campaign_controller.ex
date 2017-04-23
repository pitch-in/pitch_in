defmodule PitchIn.Web.Admin.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Web.Campaign
  alias PitchIn.Web.CampaignView

  def index(conn, _params) do
    campaigns = Repo.all(from c in Campaign, order_by: [desc: :inserted_at])

    render(conn, "index.html", campaigns: campaigns)
  end
end
