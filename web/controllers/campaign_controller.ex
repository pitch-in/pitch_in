defmodule PitchIn.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.Issue
  alias PitchIn.User
  alias PitchIn.Email
  alias PitchIn.Mailer

  use PitchIn.Auth, protect: [:index, :new, :create, :edit, :update, :delete]
  plug :check_campaign_staff, [id: "id"] when action in [:show, :edit, :update, :delete]
  plug :verify_campaign_staff when action in [:edit, :update, :delete]

  def index(conn, _params) do
    user = conn.assigns.current_user |> Repo.preload(:campaigns)

    active_campaigns = Enum.filter(user.campaigns, &(!PitchIn.ArchiveReasons.archived?(&1)))
    archived_campaigns = Enum.filter(user.campaigns, &(PitchIn.ArchiveReasons.archived?(&1)))

    render(conn, "index.html", active_campaigns: active_campaigns, archived_campaigns: archived_campaigns)
  end

  def new(conn, _params) do
    changeset =
      %Campaign{issues: []}
      |> Campaign.changeset
      |> fill_issues
    render(conn, "new.html", changeset: changeset)
  end

  def interstitial(conn, %{"id" => id}) do
    campaign = Repo.get(Campaign, id)
    render(conn, "interstitial.html", campaign: campaign)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    user = conn.assigns.current_user

    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &clean_up_issues/1)

    changeset =
      %Campaign{}
      |> Campaign.changeset(campaign_params)
      |> Ecto.Changeset.put_assoc(:users, [user])

    case Repo.insert(changeset) do
      {:ok, campaign} ->
        conn
        |> Email.admin_new_campaign_email(campaign)
        |> Mailer.deliver_later

        conn
        |> redirect(to: campaign_prefilled_ask_path(conn, :index, campaign))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    campaign = get_campaign(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id, "archive" => "true"}) do
    campaign = get_campaign(id)
    changeset = Campaign.archive_changeset(campaign)

    render(conn, "edit_archived.html", campaign: campaign, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    campaign = get_campaign(id)

    changeset =
      campaign
      |> Campaign.changeset
      |> fill_issues

    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params, "archive" => "true"}) do
    campaign = get_campaign(id)
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

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    user = conn.assigns.current_user
    campaign = get_campaign(id)

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
        user
        |> complete_user
        |> make_user_staffer

        if show_whats_next do
          conn
          |> redirect(to: campaign_prefilled_ask_path(conn, :index, campaign))
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
    Campaign |> Repo.get!(id) |> Repo.preload(:issues)
  end

  defp complete_user(user) do
    if user.is_staffer && !user.is_complete do
      changeset = User.complete_changeset(user)

      case Repo.update(changeset) do
        {:ok, user} -> user
        {:error, _} -> user
      end
    else
      user
    end
  end

  defp make_user_staffer(user) do
    if user.is_staffer do
      user
    else
      changeset = User.staffer_changeset(user)

      case Repo.update(changeset) do
        {:ok, user} -> user
        {:error, _} -> user
      end
    end
  end
end
