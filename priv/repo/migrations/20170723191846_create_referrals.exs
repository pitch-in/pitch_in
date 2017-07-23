defmodule PitchIn.Repo.Migrations.CreateReferrals do
  use Ecto.Migration

  def change do
    create table(:referrals) do
      add :code, :string
      add :email, :string
      add :referrer_id, references(:users, on_delete: :nothing)

      timestamps()
    end

  end
end
