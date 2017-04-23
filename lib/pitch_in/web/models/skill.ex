defmodule PitchIn.Web.Skill do
  use PitchIn.Web, :model

  alias PitchIn.Web.Ask

  schema "skills" do
    field :skill, :string
    belongs_to :ask, Ask

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:skill])
    |> validate_required([:skill])
  end
end
