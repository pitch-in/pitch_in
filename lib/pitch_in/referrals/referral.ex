defmodule PitchIn.Referrals.Referral do
  @moduledoc """
  A referral from a current user to a new user.
  """
  use PitchIn.Web, :model

  alias PitchIn.Users.User 
  alias PitchIn.Tokens 

  schema "referrals" do
    belongs_to :referrer, User
    field :code, :string
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> put_change(:code, generate_code())
    |> validate_required([:email])
    |> unique_constraint(:email, name: :referrals_email_referrer_index)
  end

  defp generate_code() do
    Tokens.token(6)
  end
end
