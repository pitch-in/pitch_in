defmodule PitchIn.Politics.NeedSearch do
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

  def form_changeset(struct, filter \\ %{}) do
    filter = 
      filter
      |> Map.update("issues", [], &(split_list(&1)))

    struct
    |> changeset(filter)
  end

  def split_list(nil), do: []
  def split_list(string) do
    String.split(string, ~r/\s*,\s*/, trim: true)
  end
end

