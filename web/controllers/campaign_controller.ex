defmodule PitchIn.CampaignController do
  use PitchIn.Web, :controller
  import PitchIn.Utils

  alias PitchIn.Campaign
  alias PitchIn.Issue

  def index(conn, _params) do
    user = get_user |> Repo.preload(:campaigns)
    render(conn, "index.html", campaigns: user.campaigns)
  end

  def new(conn, _params) do
    changeset =
      %Campaign{}
      |> Campaign.changeset
      |> fill_issues
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    changeset =
      Campaign.changeset(%Campaign{}, campaign_params)
      |> Ecto.Changeset.put_assoc(:users, [get_user])

    case Repo.insert(changeset) do
      {:ok, _campaign} ->
        conn
        |> put_flash(:info, "Campaign created successfully.")
        |> redirect(to: campaign_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    campaign = get_campaign(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id}) do
    campaign = get_campaign(id)
    changeset = Campaign.changeset(campaign) |> fill_issues
    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = get_campaign(id)

    campaign_params = 
      campaign_params
      |> Map.update!("issues", &clean_up_issues/1)

    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        conn
        |> put_flash(:info, "Campaign updated successfully.")
        |> redirect(to: campaign_path(conn, :edit, campaign))
      {:error, changeset} ->
        changeset = fill_issues(changeset)
        IO.inspect(changeset)
        render(conn, "edit.html", campaign: campaign, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    campaign = Repo.get!(Campaign, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(campaign)

    conn
    |> put_flash(:info, "Campaign deleted successfully.")
    |> redirect(to: campaign_path(conn, :index))
  end

  defp fill_issues(changeset) do
    campaign = Ecto.Changeset.apply_changes(changeset)
    issues = campaign.issues
    missing_issues = 5 - length(issues)
    IO.puts "--------MISSING: #{missing_issues}"

    if missing_issues < 1 do
      changeset
    else
      blanks = Enum.map(1..missing_issues, fn _ -> %Issue{} end)

      blanks_changeset =
        changeset
        |> Ecto.Changeset.put_assoc(:issues, campaign.issues ++ blanks)

      # changeset = 
      #   changeset
      #   |> update_in_struct([:data, :issues], &(&1 ++ blanks))

      # changeset
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

  defp get_user do
    Repo.get!(PitchIn.User, 2)
  end
end
