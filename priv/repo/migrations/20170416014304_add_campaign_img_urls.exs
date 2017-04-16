defmodule PitchIn.Repo.Migrations.AddCampaignImgUrls do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :img_url, :string
    end
  end
end
