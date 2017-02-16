defmodule PitchIn.Ask do
  use PitchIn.Web, :model

  schema "asks" do
    belongs_to :campaign, PitchIn.Campaign
    has_many :answers, PitchIn.Answer
    field :role, :string
    field :length, AskLengthEnum
    field :profession, :string
    field :description, :string
    field :years_experience, :integer
    field :archived_reason, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role, :length, :profession, :description, :years_experience])
    |> validate_required([:role, :length, :profession, :description, :years_experience])
  end

  def archive_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived_reason])
  end
end
