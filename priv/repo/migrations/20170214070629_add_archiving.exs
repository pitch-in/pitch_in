defmodule PitchIn.Repo.Migrations.AddArchiving do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :archived_reason, :string
    end

    alter table(:asks) do
      add :archived_reason, :string
    end

    alter table(:answers) do
      add :archived_reason, :string
    end

    alter table(:users) do
      add :archived_reason, :string
    end

  	create index(:campaigns, [:archived_reason])
  	create index(:asks, [:archived_reason])
  	create index(:answers, [:archived_reason])
  	create index(:users, [:archived_reason])
  end
end
