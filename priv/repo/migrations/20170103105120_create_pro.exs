defmodule PitchIn.Repo.Migrations.CreatePro do
  use Ecto.Migration

  def change do
    create table(:pros) do
      add :linkedin_url, :string
      add :profession, :string
      add :address_street, :string
      add :address_unit, :string
      add :address_city, :string
      add :address_state, :string
      add :address_zip, :string
      add :phone, :string
      add :experience_starts_at, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:pros, [:user_id])
  end
end
