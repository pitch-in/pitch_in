defmodule PitchIn.Repo.Migrations.CreateAsk do
  use Ecto.Migration

  def change do
    create table(:asks) do
      add :role, :string
      add :length, :integer
      add :profession, :string
      add :description, :text
      add :experience, :integer
      add :campaign_id, references(:campaigns, on_delete: :nothing)

      timestamps()
    end

    create index(:asks, [:campaign_id])
  end
end
