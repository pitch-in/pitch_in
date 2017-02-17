defmodule PitchIn.Repo.Migrations.SimpleCampaignVerification do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :is_verified, :boolean, default: false, null: false
    end
  end
end
