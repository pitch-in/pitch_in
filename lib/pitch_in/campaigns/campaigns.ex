defmodule PitchIn.Campaigns do
  @moduledoc """
  The boundary for the Campaigns system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Campaigns.Campaign
  alias PitchIn.Tags
  alias PitchIn.Tags.Issue

  def find_campaign(id) do
    Campaign
    |> Repo.get(id)
    |> Repo.preload(:asks)
    |> Repo.preload(:issues)
  end

  def campaign_changeset(campaign) do
    campaign
    |> Campaign.changeset()
    |> fill_issues()
  end

  def list_user_campaigns(staff) do
    staff = staff |> Repo.preload(:campaigns)
    staff.campaigns
  end

  def create_campaign(staff, campaign_params) do
    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &Tags.clean_up_issues/1)

    changeset =
      %Campaign{}
      |> Campaign.changeset(campaign_params)
      |> Ecto.Changeset.put_assoc(:users, [staff])

    Repo.insert(changeset)
  end

  def update_campaign(campaign, campaign_params) do
    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &Tags.clean_up_issues/1)

    changeset = 
      campaign
      |> Campaign.changeset(campaign_params)
      |> Ecto.Changeset.put_change(:shown_whats_next, true)

    Repo.update(changeset)
  end

  def fill_issues(changeset) do
    campaign = Ecto.Changeset.apply_changes(changeset)
    issues = campaign.issues
    missing_issues = 5 - length(issues)

    if missing_issues < 1 do
      changeset
    else
      blanks = Enum.map(1..missing_issues, fn _ -> %Issue{} end)

      changeset
      |> Ecto.Changeset.put_assoc(:issues, campaign.issues ++ blanks)
    end
  end
end

