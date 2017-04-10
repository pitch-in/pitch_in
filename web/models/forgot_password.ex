defmodule PitchIn.ForgotPassword do
  @moduledoc """
  Model for forgot password tokens.
  """

  use PitchIn.Web, :model

  schema "forgot_passwords" do
    field :token, :string
    belongs_to :user, PitchIn.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token])
    |> validate_required([:token])
  end
end
