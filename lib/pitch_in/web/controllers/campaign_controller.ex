defmodule PitchIn.Web.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaigns
  alias PitchIn.Users

  alias PitchIn.Campaigns.Campaign
  alias PitchIn.Tags.Issue
  alias PitchIn.Users.User
  alias PitchIn.Mail.Email
  alias PitchIn.Mail.Mailer

  use PitchIn.Web.Auth, protect: [:index, :new, :create, :edit, :update, :delete]
  plug :check_campaign_staff, [id: "id"] when action in [:show, :edit, :update, :delete]
  plug :verify_campaign_staff when action in [:edit, :update, :delete]

  def index(conn, _params) do
    user = conn.assigns.current_user |> Repo.preload(:campaigns)
    campaigns = user.campaigns

    render(conn, "index.html", campaigns: campaigns)
  end

  def new(conn, _params) do
    changeset = %Campaign{issues: []} |> Campaigns.campaign_changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def interstitial(conn, %{"id" => id}) do
    campaign = Campaigns.find_campaign(id)
    render(conn, "interstitial.html", campaign: campaign)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    user = conn.assigns.current_user

    case Campaigns.create_campaign(user, campaign_params) do
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
    campaign = Campaigns.find_campaign(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id, "archive" => "true"}) do
    campaign = Campaigns.find_campaign(id)
    changeset = Campaign.archive_changeset(campaign)

    render(conn, "edit_archived.html", campaign: campaign, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    campaign = Campaigns.find_campaign(id)
    changeset = campaign |> Campaigns.campaign_changeset()

    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params, "archive" => "true"}) do
    campaign = Campaigns.find_campaign(id)
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
    campaign = Campaigns.find_campaign(id)

    case Campaigns.update_campaign(campaign, campaign_params) do
      {:ok, campaign} ->
        user
        |> Users.complete_user
        |> Users.make_user_staffer

        if campaign.shown_whats_next do
          conn
          |> put_flash(:success, "Campaign updated successfully.")
          |> redirect(to: campaign_path(conn, :edit, campaign))
        else
          conn
          |> redirect(to: campaign_prefilled_ask_path(conn, :index, campaign))
        end
      {:error, changeset} ->
        changeset = Campaigns.fill_issues(changeset)
        render(conn, "edit.html", campaign: campaign, changeset: changeset)
    end
  end

end
