defmodule PitchIn.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :is_admin, :boolean, default: false, null: false
      add :email, :string

      timestamps()
    end

  	create unique_index(:users, [:email])
  end
end
