defmodule PitchIn.Repo.Migrations.CreateForgotPassword do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reset_digest, :string
      add :reset_time, :utc_datetime
    end
  end
end
