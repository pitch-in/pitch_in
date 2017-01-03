defmodule PitchIn.User do
  use PitchIn.Web, :model

  schema "users" do
    many_to_many :campaigns, PitchIn.Campaign, join_through: "campaign_staff"
    has_one :pro, PitchIn.Pro
    has_many :answers, PitchIn.Answer
    field :name, :string
    field :is_admin, :boolean, default: false
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> IO.inspect
    |> cast(params, [:name, :email])
    |> cast_assoc(:pro)
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end
end
