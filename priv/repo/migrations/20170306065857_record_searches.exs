defmodule PitchIn.Repo.Migrations.RecordSearches do
  use Ecto.Migration

  def change do
    create table(:need_searches) do
      add :profession, :string
      add :years_experience, :integer
      add :issue, :string
      add :found_count, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
