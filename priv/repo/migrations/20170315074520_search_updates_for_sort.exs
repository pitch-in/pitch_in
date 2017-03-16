defmodule PitchIn.Repo.Migrations.SearchUpdatesForSort do
  use Ecto.Migration

  def change do
    alter table(:need_searches) do
      add :issues, {:array, :string}, default: []
      remove :found_count
    end
  end
end
