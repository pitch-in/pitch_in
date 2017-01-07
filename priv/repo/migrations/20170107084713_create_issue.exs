defmodule PitchIn.Repo.Migrations.CreateIssue do
  use Ecto.Migration

  def change do
    create table(:issues) do
      add :issue, :string
      add :campaign_id, references(:campaigns, on_delete: :nothing)

      timestamps()
    end
    create index(:issues, [:campaign_id])
    create index(:issues, [:issue])
  end
end
