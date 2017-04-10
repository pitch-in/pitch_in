defmodule PitchIn.Repo.Migrations.CreateForgotPassword do
  use Ecto.Migration

  def change do
    create table(:forgot_passwords) do
      add :token, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:forgot_passwords, [:user_id])
  end
end
