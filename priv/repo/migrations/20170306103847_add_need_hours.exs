defmodule PitchIn.Repo.Migrations.AddNeedHours do
  use Ecto.Migration

  def change do
    alter table(:asks) do
      add :hours, :integer
    end
  end
end
