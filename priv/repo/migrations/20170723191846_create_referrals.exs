defmodule PitchIn.Repo.Migrations.CreateReferrals do
  use Ecto.Migration

  def change do
    create table(:referrals) do
      add :code, :string
      add :email, :string
      add :referrer_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:referrals, :code)
    create unique_index(:referrals, [:email, :referrer_id], name: :referrals_email_referrer_index)
  end
end
