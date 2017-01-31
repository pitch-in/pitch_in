defmodule PitchIn.User do
  use PitchIn.Web, :model

  schema "users" do
    many_to_many :campaigns, PitchIn.Campaign, join_through: "campaign_staff"
    has_one :pro, PitchIn.Pro
    has_many :answers, PitchIn.Answer
    field :name, :string
    field :is_admin, :boolean, default: false
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> cast_assoc(:pro)
    |> validate_required([:name, :email])
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
  end

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
