defmodule PitchIn.NeedSearch do
  use PitchIn.Web, :model

  schema "need_searches" do
    belongs_to :user, PitchIn.User

    field :skills, :string
    field :years_experience, :integer
    field :issues, {:array, :string}, default: []

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:skills, :years_experience, :issues])
  end
end

