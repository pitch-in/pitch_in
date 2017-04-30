defmodule PitchIn.Web.Issue do
  use PitchIn.Web, :model

  alias PitchIn.Web.Campaign 

  schema "issues" do
    field :issue, :string
    belongs_to :campaign, Campaign

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:issue])
    |> validate_required([:issue])
  end
end
