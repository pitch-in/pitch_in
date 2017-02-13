defmodule PitchIn.Repo.Migrations.RemoveFields do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :percent_dem
    end

    alter table(:answers) do
      remove :share_email
      remove :share_phone
      remove :share_address
    end
  end
end
