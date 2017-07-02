defmodule PitchIn.Politics.SearchAlert do
  use PitchIn.Web, :model

  alias PitchIn.Web.User

  schema "search_alerts" do
    belongs_to :user, User

    field :skills, :string
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
    |> cast(params, [:skills, :role, :years_experience, :issue])
    |> unique_constraint(:unique_alerts, name: :unique_alerts)
  end
end
