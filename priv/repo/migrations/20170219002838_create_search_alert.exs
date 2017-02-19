defmodule PitchIn.Repo.Migrations.CreateSearchAlert do
  use Ecto.Migration

  def change do
    create table(:search_alerts) do
      add :profession, :string
      add :role, :string
      add :years_experience, :integer
      add :issue, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:search_alerts, [:user_id])
  end
end
