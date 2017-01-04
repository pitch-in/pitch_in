defmodule PitchIn.CampaignView do
  use PitchIn.Web, :view

  alias PitchIn.Campaign

  def candidate?(campaign), do: campaign.type == :candidate
  def measure?(campaign), do: campaign.type == :measure
  def issue?(campaign), do: campaign.type == :issue
  def election?(campaign), do: candidate?(campaign) || measure?(campaign)
end
