defmodule PitchIn.Answer do
  use PitchIn.Web, :model
  use PitchIn.NextSteps

  @derive [PitchIn.Archivable]

  schema "answers" do
    belongs_to :user, PitchIn.User
    belongs_to :ask, PitchIn.Ask
    has_one :campaign, through: [:ask, :campaign]
    belongs_to :direct_campaign, PitchIn.Campaign
    field :message, :string
    field :archived_reason, :string

    timestamps()
  end

  next_step_list do
    step :search
    step :campaign_needs
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message])
    |> validate_required([:message])
  end

  def archive_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived_reason])
  end
end
