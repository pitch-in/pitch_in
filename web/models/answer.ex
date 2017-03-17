defmodule PitchIn.Answer do
  use PitchIn.Web, :model
  use PitchIn.NextSteps

  schema "answers" do
    belongs_to :user, PitchIn.User
    belongs_to :ask, PitchIn.Ask
    has_one :campaign, through: [:ask, :campaign]
    field :message, :string

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
end
