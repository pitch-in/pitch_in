defmodule PitchIn.Campaign do
  use PitchIn.Web, :model

  schema "campaigns" do
    many_to_many :users, PitchIn.User, join_through: "campaign_staff"
    has_many :asks, PitchIn.Ask
    has_many :issues, PitchIn.Issue, on_replace: :delete
    field :name, :string
    field :email, :string
    field :type, CampaignTypeEnum
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
    field :election_date, Timex.Ecto.Date
    field :is_partisan, :boolean, default: false
    field :current_party, PartyEnum

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :type, :state, :district, :candidate_name, :measure_name, :measure_position, :short_pitch, :long_pitch, :website_url, :twitter_url, :facebook_url, :candidate_profession, :election_date, :is_partisan, :current_party])
    |> cast_assoc(:issues)
    |> validate_required([:name, :email, :type, :short_pitch])
  end
end
