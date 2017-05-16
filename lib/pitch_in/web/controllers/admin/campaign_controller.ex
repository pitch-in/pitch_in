defmodule PitchIn.Web.Admin.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Web.Campaign
  alias PitchIn.Web.CampaignView

  def index(conn, _params) do
    campaigns = Repo.all(from c in Campaign, order_by: [desc: :inserted_at])

    render(conn, "index.html", campaigns: campaigns)
  end

  def update(conn,  %{"id" => id, "campaign" => campaign_params}) do
    campaign = Repo.get(Campaign, id)

    changeset = 
      campaign
      |> Campaign.admin_changeset(campaign_params)
    
    case Repo.update(changeset) do
    {:ok, _} ->
      conn
      |> put_flash(:success, "#{campaign.name} updated!")
      |> redirect(to: admin_campaign_path(conn, :index))
    {:error, changeset} ->
      conn
      |> put_flash(:alert, "#{campaign.name} update failed!")
      |> redirect(to: admin_campaign_path(conn, :index))
    end

  end
end
