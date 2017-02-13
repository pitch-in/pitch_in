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
      :experience_starts_at
    ])
    |> validate_required([:phone])
    |> unique_constraint(:user_id)
  end
end
