defmodule PitchIn.Pro do
  use PitchIn.Web, :model

  schema "pros" do
    belongs_to :user, PitchIn.User
    field :linkedin_url, :string
    field :twitter_handle, :string
    field :github_handle, :string
    field :profession, :string
    field :address_zip, :string
    field :phone, :string
    field :experience_starts_at, PitchIn.UsDate
    field :issues, :string
    field :intro, :string
    field :has_campaign_experience, :boolean

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params,
    [
      :linkedin_url,
      :twitter_handle,
      :github_handle,
      :profession,
      :address_zip,
      :phone,
      :experience_starts_at,
      :intro,
      :has_campaign_experience,
      :issues
    ])
    |> validate_required([:phone])
    |> unique_constraint(:user_id)
    |> validate_url(:linkedin_url)
    |> validate_zip(:address_zip)
    |> validate_one_word(:github_handle)
    |> validate_one_word(:twitter_handle)
  end
end
