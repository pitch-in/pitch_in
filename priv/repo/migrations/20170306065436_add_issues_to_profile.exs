defmodule PitchIn.Repo.Migrations.AddIssuesToProfile do
  use Ecto.Migration

  def change do
    alter table(:pros) do
      add :issues, :string
    end
  end
end
