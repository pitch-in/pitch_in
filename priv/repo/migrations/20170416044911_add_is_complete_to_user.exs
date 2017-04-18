defmodule PitchIn.Repo.Migrations.AddIsCompleteToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_complete, :boolean, default: false, null: false
      add :is_staffer, :boolean, default: false, null: false
    end
  end
end
