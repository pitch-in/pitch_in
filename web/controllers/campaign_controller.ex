defmodule PitchIn.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.Issue
  alias PitchIn.User

  use PitchIn.Auth, protect: [:edit, :update, :delete], pass_user: true

  def index(conn, _params, user) do
    user = user |> Repo.preload(:campaigns)
    render(conn, "index.html", campaigns: user.campaigns)
  end

  def new(conn, _params, _user) do
    changeset =
      %Campaign{issues: []}
      |> Campaign.changeset
      |> fill_issues
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"campaign" => campaign_params}, user) do
    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &clean_up_issues/1)

    changeset =
      Campaign.changeset(%Campaign{}, campaign_params)
      |> Ecto.Changeset.put_assoc(:users, [user])

    case Repo.insert(changeset) do
      {:ok, _campaign} ->
        conn
        |> put_flash(:primary, "Campaign created successfully.")
        |> redirect(to: campaign_path(conn, :index))
      {:error, changeset} ->
        IO.inspect changeset.errors
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    campaign = get_campaign(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id}, user) do
    campaign = get_campaign(id, user)

    changeset =
      campaign
      |> Campaign.changeset
      |> fill_issues

    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}, user) do
    campaign = get_campaign(id, user)

    campaign_params = 
      campaign_params
      |> Map.update("issues", [], &clean_up_issues/1)

    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        conn
        |> put_flash(:primary, "Campaign updated successfully.")
        |> redirect(to: campaign_path(conn, :edit, campaign))
      {:error, changeset} ->
        changeset = fill_issues(changeset)
        render(conn, "edit.html", campaign: campaign, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    campaign = get_campaign(id, user)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(campaign)

    conn
    |> put_flash(:primary, "Campaign deleted successfully.")
    |> redirect(to: campaign_path(conn, :index))
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

  defp verify_staff(conn, _opts) do
    {param_id, _} = Integer.parse(conn.params["id"])

    if param_id == conn.assigns.current_user.id do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:alert, "You don't have access to that page.")
      |> put_status(404)
      |> render(PitchIn.ErrorView, "404.html")
      |> halt
    end
  end
end
