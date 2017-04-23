defmodule PitchIn.Web.CampaignStaff do
  use PitchIn.Web, :model

  schema "campaign_staff" do
    field :user_id, :integer
    field :campaign_id, :integer
  end
end
