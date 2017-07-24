defmodule PitchIn.Referrals do
  @moduledoc """
  The boundary for the Referrals system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Referrals.Referral
  alias PitchIn.Web.User

  @starting_slots 5

  def add_referral(%User{} = referrer, email) do
    changeset =
      referrer
      |> build_assoc(:referrals)
      |> Referral.changeset(%{email: email})

    Repo.insert(changeset)
  end

  def list_referrals(%User{} = referrer) do
    Repo.all(Referral, referrer_id: referrer.id)
  end

  def filter_open_referrals(referrals) do

  end

  def filter_pending_referrals(referrals) do

  end

  def filter_closed_referrals(referrals) do

  end

  def referral_slots(%User{} = referrer) do
    @starting_slots

    referrals = list_referrals(referrer)

    total_count = referrals |> length()
    closed_count = referrals |> filter_open_referrals() |> length()

    @starting_slots - (total_count - closed_count)
  end

  def referral_changeset(params \\ %{}) do
    Referral.changeset(%Referral{}, params)
  end
end
