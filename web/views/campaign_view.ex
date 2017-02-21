defmodule PitchIn.CampaignView do
  use PitchIn.Web, :view

  alias PitchIn.Campaign
  alias PitchIn.Issue
  use PitchIn.NextStepView

  def candidate?(campaign), do: campaign.type == :candidate
  def measure?(campaign), do: campaign.type == :measure
  def issue?(campaign), do: campaign.type == :issue
  def election?(campaign), do: candidate?(campaign) || measure?(campaign)

  def unarchive_button(conn, campaign) do
    render("_unarchive.html", conn: conn, campaign: campaign)
  end

  def archive_button(conn, campaign, opts \\ []) do
    opts =
      Keyword.merge([
        to: campaign_path(conn, :edit, campaign, archive: true),
        class: "alert button"],
        opts
      )

    if !campaign.archived_reason do
      link("Archive", opts)
    end
  end
end
