defmodule PitchIn.Referrals do
  @moduledoc """
  The boundary for the Referrals system.
  """

  import Ecto, warn: false
  import Ecto.{Query, Changeset}, warn: false
  alias PitchIn.Repo

  alias PitchIn.Referrals.Referral
  alias PitchIn.Web.User
  alias PitchIn.Email

  @email Application.get_env(:pitch_in, :email, Email)

  def add_referral(%User{} = referrer, email) do
    changeset =
      referrer
      |> build_assoc(:referral)
      |> Referral.changeset(%{email: email})

    Repo.insert(changeset)
  end

  def email_referral(%Referral{} = referral) do

  end

  def list_referrals(%User{} = referrer) do

  end

  def list_open_referrals(%User{} = referrer) do

  end

  def referral_slots(%User{} = referrer) do

  end
end
