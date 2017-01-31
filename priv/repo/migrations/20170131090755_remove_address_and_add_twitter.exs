defmodule PitchIn.Repo.Migrations.RemoveAddressAndAddTwitter do
  use Ecto.Migration

  def change do
    alter table(:pros) do
      add :twitter_handle, :string
      add :github_handle, :string

      remove :address_street
      remove :address_unit
      remove :address_city
      remove :address_state
    end
  end
end
