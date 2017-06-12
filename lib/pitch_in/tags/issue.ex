defmodule PitchIn.Tags.Issue do
  @moduledoc """
  An important political issue for a campaign or user.
  """
  use PitchIn.Web, :model
  # use Ecto.Schema

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

defimpl PitchIn.Tags.Tag, for: Any do
end

