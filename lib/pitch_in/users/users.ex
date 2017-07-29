defmodule PitchIn.Users do
  @moduledoc """
  The boundary for the Users system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Users.User
  alias PitchIn.Users.Pro
  alias PitchIn.Users.CampaignStaff

  def complete_user(user) do
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

  def make_user_staffer(user) do
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
