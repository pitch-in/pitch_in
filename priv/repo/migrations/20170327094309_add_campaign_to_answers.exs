defmodule PitchIn.Repo.Migrations.AddCampaignToAnswers do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :direct_campaign_id, references(:campaigns, on_delete: :nothing)
    end

    create index(:answers, [:direct_campaign_id])
  end
end
