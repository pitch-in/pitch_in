defmodule PitchIn.Repo.Migrations.AddShownWhatsNextToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :shown_whats_next, :boolean, default: true, null: false
    end
  end
end
