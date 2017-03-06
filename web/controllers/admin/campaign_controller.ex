defmodule PitchIn.Admin.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.CampaignView

  def index(conn, _params) do
    campaigns = Repo.all(from c in Campaign, order_by: [desc: :inserted_at])

    active_campaigns = Enum.filter(campaigns, &(!PitchIn.ArchiveReasons.archived?(&1)))
    archived_campaigns = Enum.filter(campaigns, &(PitchIn.ArchiveReasons.archived?(&1)))

    render(conn, "index.html", active_campaigns: active_campaigns, archived_campaigns: archived_campaigns)
  end
end
