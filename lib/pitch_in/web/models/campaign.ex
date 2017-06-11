defmodule PitchIn.Web.Campaign do
  use PitchIn.Web, :model
  use PitchIn.Web.NextSteps

  alias PitchIn.Web.User
  alias PitchIn.Web.Ask
  alias PitchIn.Web.Answer
  alias PitchIn.Tags.Issue
  alias PitchIn.UsDate

  @derive [PitchIn.Archivable]

  schema "campaigns" do
    many_to_many :users, User, join_through: "campaign_staff"
    has_many :asks, Ask
    has_many :answers, through: [:asks, :answers]
    has_many :direct_answers, Answer, foreign_key: :direct_campaign_id
    has_many :issues, Issue, on_replace: :delete
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
    field :img_url, :string

    timestamps()
  end

  next_step_list do
    step :first_need
    step :list_needs, :show_list_needs_step
    step :file_number, :show_file_number_step
    step :edit_campaign
  end

  def show_list_needs_step(campaign) do
    campaign.asks != []
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

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_verified])
  end

  def archive_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:archived_reason])
  end
end
 
