defmodule PitchIn.Web.NeedSearch do
  use PitchIn.Web, :model

  alias PitchIn.Web.User

  schema "need_searches" do
    belongs_to :user, User

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

