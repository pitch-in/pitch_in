defmodule PitchIn.Repo.Migrations.CreateAnswer do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :share_email, :boolean, default: false, null: false
      add :share_phone, :boolean, default: false, null: false
      add :share_address, :boolean, default: false, null: false
      add :message, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :ask_id, references(:asks, on_delete: :nothing)

      timestamps()
    end
    create index(:answers, [:user_id])
    create index(:answers, [:ask_id])

  end
end
