defmodule PitchIn.Repo.Migrations.CreateCampaign do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add :name, :string
      add :type, :integer
      add :state, :string
      add :district, :string
      add :candidate_name, :string
      add :measure_name, :string
      add :measure_position, :string
      add :short_pitch, :string
      add :long_pitch, :text
      add :website_url, :string
      add :twitter_url, :string
      add :facebook_url, :string
      add :candidate_profession, :string
      add :election_date, :date
      add :is_partisan, :boolean, default: false, null: false
      add :percent_dem, :integer
      add :current_party, :integer

      timestamps()
    end

  	create index(:campaigns, [:state])
  	create index(:campaigns, [:percent_dem], where: "is_partisan = TRUE")
  	create index(:campaigns, [:current_party], where: "is_partisan = TRUE")
  end
end
