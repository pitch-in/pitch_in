defmodule PitchIn.Ask do
  use PitchIn.Web, :model
  use PitchIn.NextSteps

  schema "asks" do
    belongs_to :campaign, PitchIn.Campaign
    has_many :answers, PitchIn.Answer
    has_many :skills, PitchIn.Skill, on_replace: :delete
    field :role, :string
    field :length, AskLengthEnum
    field :hours, :integer
    field :description, :string
    field :years_experience, :integer
    field :archived_reason, :string

    # TODO: Remove
    field :profession, :string

    timestamps()
  end

  next_step_list do
    step :another_need
    step :update_campaign
    step :view_need
    step :edit_need
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role, :length, :description, :years_experience, :hours])
    |> validate_required([:role, :length, :description, :years_experience, :hours])
    |> skills_changeset(params)
  end

  def archive_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived_reason])
  end

  defp skills_changeset(changeset, params \\ %{}) do
    if params["skills"] do
      params = Map.update!(params, "skills", &skills_string_to_maps/1)

      changeset
      |> cast(params, [])
      |> cast_assoc(:skills, params["skills"])
    else
      changeset
    end
  end

  defp skills_string_to_maps(skills) do
    skills
    |> String.split(",")
    |> Enum.map(fn skill -> %{"skill" => skill} end)
  end
end
