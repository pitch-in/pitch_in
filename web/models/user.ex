defmodule PitchIn.User do
  @moduledoc """
  A volunteer or campaign user.
  """

  use PitchIn.Web, :model
  use PitchIn.NextSteps

  alias PitchIn.Tokens

  schema "users" do
    many_to_many :campaigns, PitchIn.Campaign, join_through: "campaign_staff"
    has_one :pro, PitchIn.Pro
    has_many :answers, PitchIn.Answer
    has_many :search_alerts, PitchIn.SearchAlert
    has_many :need_searches, PitchIn.NeedSearch
    field :name, :string
    field :is_admin, :boolean, default: false
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :reset_token, :string, virtual: true
    field :reset_digest, :string
    field :reset_time, Timex.Ecto.DateTime

    timestamps()
  end

  next_step_list do
    step :search
    step :profile
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
    |> validate_email
    |> unique_constraint(:email)
  end

  def volunteer_registration_changeset(struct, params \\ %{}) do
    struct
    |> registration_changeset(params)
    |> cast_assoc(:pro)
  end

  def staff_registration_changeset(struct, params \\ %{}) do
    struct
    |> registration_changeset(params)
    |> cast_assoc(:campaigns)
    |> put_assoc(:pro, %PitchIn.Pro{})
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash
  end

  def forgot_password_changeset(struct, params \\ %{}) do
    token = Tokens.token

    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> put_change(:reset_token, token)
    |> put_change(:reset_digest, Comeonin.Bcrypt.hashpwsalt(token))
    |> put_change(:reset_time, Timex.now)
  end

  defp registration_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> password_changeset(params)
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
