defmodule PitchIn.Ask do
  use PitchIn.Web, :model

  schema "asks" do
    belongs_to :campaign, PitchIn.Campaign
    has_many :answers, PitchIn.Answer
    field :role, :string
    field :length, AskLengthEnum
    field :profession, :string
    field :description, :string
    field :experience, ExperienceEnum

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role, :length, :profession, :description, :experience])
    |> validate_required([:role, :length, :profession, :description, :experience])
  end
end
