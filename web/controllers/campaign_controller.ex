defmodule PitchIn.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.Issue
  alias PitchIn.User

  use PitchIn.Auth, protect: :all, pass_user: true
  plug :check_campaign_staff, [id: "id"] when action in [:show, :edit, :update, :delete]
  plug :verify_campaign_staff when action in [:edit, :update, :delete]

  def index(conn, _params, user) do
    user = user |> Repo.preload(:campaigns)

    active_campaigns = Enum.filter(user.campaigns, &(!PitchIn.ArchiveReasons.archived?(&1)))
    archived_campaigns = Enum.filter(user.campaigns, &(PitchIn.ArchiveReasons.archived?(&1)))

    render(conn, "index.html", active_campaigns: active_campaigns, archived_campaigns: archived_campaigns)
  end

  def new(conn, _params, _user) do
    changeset =
      %Campaign{issues: []}
      |> Campaign.changeset
      |> fill_issues
    render(conn, "new.html", changeset: changeset)
  end

  def interstitial(conn, %{"id" => id}, _user) do
    campaign = Repo.get(Campaign, id)
    render(conn, "interstitial.html", campaign: campaign)
  end

  def create(conn, %{"campaign" => campaign_params}, user) do
    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &clean_up_issues/1)

    changeset =
      Campaign.changeset(%Campaign{}, campaign_params)
      |> Ecto.Changeset.put_assoc(:users, [user])

    case Repo.insert(changeset) do
      {:ok, campaign} ->
        conn
        |> redirect(to: campaign_path(conn, :interstitial, campaign))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    campaign = get_campaign(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id, "archive" => "true"}, user) do
    campaign = get_campaign(id, user)
    changeset = Campaign.archive_changeset(campaign)

    render(conn, "edit_archived.html", campaign: campaign, changeset: changeset)
  end

  def edit(conn, %{"id" => id}, user) do
    campaign = get_campaign(id, user)

    changeset =
      campaign
      |> Campaign.changeset
      |> fill_issues

    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params, "archive" => "true"}, user) do
    campaign = get_campaign(id, user)
    changeset = campaign |> Campaign.archive_changeset(campaign_params)

    case Repo.update(changeset) do
      {:ok, %{archived_reason: nil} = campaign} ->
        conn
        |> put_flash(:success, "Campaign successfully unarchived!")
        |> redirect(to: campaign_path(conn, :edit, campaign))
      {:ok, %{archived_reason: _} = campaign} ->
        conn
        |> put_flash(:warning, "Campaign successfully archived.")
        |> redirect(to: campaign_path(conn, :show, campaign))
      {:error, changeset} ->
        render(conn, "edit_archived.html", campaign: campaign, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}, user) do
    campaign = get_campaign(id, user)

    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &clean_up_issues/1)

    show_whats_next = !campaign.shown_whats_next

    changeset = 
      campaign
      |> Campaign.changeset(campaign_params)
      |> Ecto.Changeset.put_change(:shown_whats_next, true)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        if show_whats_next do
          conn
          |> redirect(to: campaign_path(conn, :interstitial, campaign))
        else
          conn
          |> put_flash(:success, "Campaign updated successfully.")
          |> redirect(to: campaign_path(conn, :edit, campaign))
        end
      {:error, changeset} ->
        changeset = fill_issues(changeset)
        render(conn, "edit.html", campaign: campaign, changeset: changeset)
    end
  end


  defp fill_issues(changeset) do
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

  defp clean_up_issues(issues) do
    issues
    # Trim each issue.
    |> Enum.map(fn {i, issue} ->
      issue = Map.update!(issue, "issue", &(String.trim(&1)))
      {i, issue}
    end)
    # Remove blank issues.
    |> Enum.reject(fn {_i, issue} ->
      issue["issue"] == ""
    end)
    |> Enum.into(%{})
  end

  defp get_campaign(id) do
    Repo.get!(PitchIn.Campaign, id) |> Repo.preload(:issues)
  end
  defp get_campaign(id, user) do
    user =
      user
      |> Repo.preload(campaigns: from(c in Campaign, where: c.id == ^id))

    # TODO: Handle not found.
    [campaign] = user.campaigns
    campaign |> Repo.preload(:issues)
  end

end
