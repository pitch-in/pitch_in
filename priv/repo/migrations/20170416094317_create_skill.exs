defmodule PitchIn.Repo.Migrations.CreateSkill do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :skill, :string
      add :ask_id, references(:asks, on_delete: :nothing)

      timestamps()
    end

    rename table(:need_searches), :profession, to: :skills
    rename table(:search_alerts), :profession, to: :skills

    create index(:skills, [:ask_id])
    create index(:skills, [:skill])
  end
end
