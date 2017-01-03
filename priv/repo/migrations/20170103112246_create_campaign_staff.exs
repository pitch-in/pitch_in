defmodule PitchIn.Repo.Migrations.CreateCampaignStaff do
  use Ecto.Migration

  def change do
    create table(:campaign_staff, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing)
      add :campaign_id, references(:campaigns, on_delete: :nothing)
    end

    create index(:campaign_staff, [:user_id])
    create index(:campaign_staff, [:campaign_id])
  end
end
