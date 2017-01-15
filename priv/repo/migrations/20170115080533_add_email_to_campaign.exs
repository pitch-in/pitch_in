defmodule PitchIn.Repo.Migrations.AddEmailToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :email, :string
    end
  end
end
