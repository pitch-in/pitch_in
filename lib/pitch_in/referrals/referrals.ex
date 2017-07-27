defmodule PitchIn.Referrals do
  @moduledoc """
  The boundary for the Referrals system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Referrals.Referral
  alias PitchIn.Referrals.ReferralForm
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
    referrer_id = referrer.id
    Repo.all(from r in Referral, where: r.referrer_id == ^referrer_id)
  end

  def get_referral_by_code(email, code) do
    case Repo.get_by(Referral, email: email, code: code) do
      nil -> {:error}
      referral -> {:ok, referral}
    end
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

  def validate_referral(params \\ %{}) do
    changeset = referral_changeset(params)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else 
      {:error, changeset}
    end
  end

  def referral_changeset(params \\ %{}) do
    ReferralForm.changeset(%ReferralForm{}, params)
  end
end
