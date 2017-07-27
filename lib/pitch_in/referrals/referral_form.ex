defmodule PitchIn.Referrals.ReferralForm do
  @moduledoc """
  The model for the referal form.
  """
  use PitchIn.Web, :model

  embedded_schema do
    field :email, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
  end
end

