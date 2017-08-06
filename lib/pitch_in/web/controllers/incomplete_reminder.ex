defmodule PitchIn.Web.IncompleteReminder do
  @moduledoc """
  Plug for reminders to finish setting up a profile/campaign.
  """

  import Plug.Conn
  import Ecto
  import Ecto.Query
  import Phoenix.Controller, only: [put_flash: 3]
  import Phoenix.HTML.Link

  alias PitchIn.Repo
  alias PitchIn.Campaigns.CampaignStaff

  def init(opts) do
    opts
  end

  def call(conn, repo) do
    user = conn.assigns.current_user

    if incomplete_user?(user) do
      {name, path, update_path, whats_next_path} = page_to_complete(conn, user)

      if show_flash?(conn, [path, update_path, whats_next_path]) do
        warning =
          ["We hardly know you! Take a moment to finish your #{name}: ",
           link("click here", to: path)]

        conn
        |> put_flash(:warning, warning)
      else
        conn
      end
    else
      conn
    end
  end

  defp incomplete_user?(nil), do: false
  defp incomplete_user?(user) do
    !user.is_complete
  end

  defp first_campaign_id(user) do
    query = 
      from cs in CampaignStaff,
      select: [:campaign_id],
      where: cs.user_id == ^user.id

    campaign_staff = Repo.one!(query |> first(:campaign_id))
    campaign_staff.campaign_id
  end

  defp page_to_complete(conn, user) do
    if user.is_staffer do
      campaign_id = first_campaign_id(user)
      {
        "campaign",
        PitchIn.Web.Router.Helpers.campaign_path(conn, :edit, campaign_id),
        PitchIn.Web.Router.Helpers.campaign_path(conn, :update, campaign_id),
        PitchIn.Web.Router.Helpers.campaign_path(conn, :interstitial, campaign_id),
       }
    else
      {
        "profile",
        PitchIn.Web.Router.Helpers.pro_path(conn, :show, user.id),
        PitchIn.Web.Router.Helpers.pro_path(conn, :update, user.id),
        PitchIn.Web.Router.Helpers.user_path(conn, :interstitial, user.id)
      }
    end
  end

  defp show_flash?(conn, paths) do
    not conn.request_path in paths
  end
end
