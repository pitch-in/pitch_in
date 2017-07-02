defmodule PitchIn.Politics do
  @moduledoc """
  The boundary for the Politics system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Need
  alias PitchIn.Politics.NeedSearch
  alias PitchIn.Politics.SearchAlert

  def record_search(user, search_changeset) do
    search_changeset = 
      search_changeset
      |> put_assoc(:user, user)

    Repo.insert(search_changeset)
  end

  def validate_search(params) do
    changeset =
      %NeedSearch{}
      |> NeedSearch.form_changeset(params)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  def search_changeset() do
    %NeedSearch{} |> NeedSearch.changeset
  end

  def insert_alert(user, search_params) do
    alert_changeset = 
      %SearchAlert{}
      |> SearchAlert.changeset(search_params)
      |> put_assoc(:user, user)

    Repo.insert(alert_changeset)
  end

  def delete_alert() do
  end
end
