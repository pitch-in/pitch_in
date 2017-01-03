defmodule PitchIn.Answer do
  use PitchIn.Web, :model

  schema "answers" do
    belongs_to :user, PitchIn.User
    belongs_to :ask, PitchIn.Ask
    field :share_email, :boolean, default: false
    field :share_phone, :boolean, default: false
    field :share_address, :boolean, default: false
    field :message, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:share_email, :share_phone, :share_address, :message])
    |> validate_required([:share_email, :share_phone, :share_address, :message])
  end
end
