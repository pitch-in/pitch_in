defmodule PitchIn.Repo.Migrations.SwitchToYearsExp do
  use Ecto.Migration

  def change do
    alter table(:asks) do
      remove :experience
      add :years_experience, :integer
    end

  end
end
