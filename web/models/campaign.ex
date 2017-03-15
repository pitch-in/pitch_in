defmodule PitchIn.Campaign do
  use PitchIn.Web, :model
  use PitchIn.NextSteps

  schema "campaigns" do
    many_to_many :users, PitchIn.User, join_through: "campaign_staff"
    has_many :asks, PitchIn.Ask
    has_many :issues, PitchIn.Issue, on_replace: :delete
    field :name, :string
    field :email, :string
    field :type, CampaignTypeEnum
    field :file_number, :string
    field :state, :string
    field :district, :string
    field :candidate_name, :string
    field :measure_name, :string
    field :measure_position, :string
    field :short_pitch, :string
    field :long_pitch, :string
    field :website_url, :string
    field :twitter_url, :string
    field :facebook_url, :string
    field :candidate_profession, :string
    field :election_date, PitchIn.UsDate
    field :is_partisan, :boolean, default: false
    field :current_party, PartyEnum
    field :archived_reason, :string
    field :is_verified, :boolean
    field :shown_whats_next, :boolean

    timestamps()
  end

  next_step_list do
    step :first_need
    step :file_number, :show_file_number_step
    step :edit_campaign
  end

  def show_file_number_step(campaign) do
    (campaign.type == :candidate || 
      campaign.type == :measure) &&
      !(campaign.file_number && campaign.state)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :type, :file_number, :state, :district, :candidate_name, :measure_name, :measure_position, :short_pitch, :long_pitch, :website_url, :twitter_url, :facebook_url, :candidate_profession, :election_date, :is_partisan, :current_party, :shown_whats_next])
    |> cast_assoc(:issues)
    |> validate_required([:name, :email, :type, :short_pitch])
    |> validate_email
    |> validate_url(:website_url)
    |> validate_url(:facebook_url)
  end

  def archive_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived_reason])
  end
end
 
