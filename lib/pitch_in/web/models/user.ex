defmodule PitchIn.Web.User do
  @moduledoc """
  A volunteer or campaign user.
  """

  use PitchIn.Web, :model
  use PitchIn.Web.NextSteps

  alias PitchIn.Tokens
  alias PitchIn.Web.Pro
  alias PitchIn.Web.Campaign
  alias PitchIn.Web.Ask
  alias PitchIn.Web.Answer
  alias PitchIn.Politics.SearchAlert
  alias PitchIn.Politics.NeedSearch
  alias PitchIn.Referrals.Referral

  schema "users" do
    many_to_many :campaigns, Campaign, join_through: "campaign_staff"
    has_one :pro, Pro
    has_many :answers, Answer
    has_many :search_alerts, SearchAlert
    has_many :need_searches, NeedSearch
    has_many :referrals, Referral
    field :name, :string
    field :is_admin, :boolean, default: false
    field :email, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    field :reset_token, :string, virtual: true
    field :reset_digest, :string
    field :reset_time, Timex.Ecto.DateTime

    field :is_complete, :boolean
    field :is_staffer, :boolean

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
    |> cast(params, [:name, :email, :is_complete])
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
    |> put_assoc(:pro, %Pro{})
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

  def complete_changeset(struct) do
    struct
    |> change(is_complete: true)
  end

  def staffer_changeset(struct) do
    struct
    |> change(is_staffer: true)
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
