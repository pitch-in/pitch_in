defmodule PitchIn.Repo.Migrations.AddInfoToPros do
  use Ecto.Migration

  def change do
    alter table(:pros) do
      add :intro, :string
      add :has_campaign_experience, :boolean, default: false, null: false
    end
  end
end
