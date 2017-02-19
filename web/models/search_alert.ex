defmodule PitchIn.SearchAlert do
  use PitchIn.Web, :model

  schema "search_alerts" do
    belongs_to :user, PitchIn.User

    field :profession, :string
    field :role, :string
    field :years_experience, :integer
    field :issue, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:profession, :role, :years_experience, :issue])
  end
end
