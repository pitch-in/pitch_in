defmodule PitchIn.Factory do
  @moduledoc """
  Sets up ExMachina factories
  """
  import ExMachina, only: [sequence: 2]

  alias PitchIn.Repo

  alias PitchIn.Tags.Issue
  alias PitchIn.Campaigns.Campaign
  alias PitchIn.Users.User
  alias PitchIn.Users.Pro
  alias PitchIn.Referrals.Referral
  alias PitchIn.Tokens 

  def build(:issue) do
    %Issue{issue: "testing"}
  end

  def build(:campaign) do
    %Campaign{}
  end

  def build(:user) do
    %User{
      name: "Bob D. Builder",
      email: sequence(:email, &"bob+#{&1}@canibuildit.com"),
      password_hash: Comeonin.Bcrypt.hashpwsalt("Password12"),
    }
  end

  def with_pro(%User{} = user) do
    %User{user | pro: build(:pro)}
  end

  def with_forgot_password(%User{} = user, token) do
    %User{user |
      reset_digest: Comeonin.Bcrypt.hashpwsalt(token),
      reset_time: Timex.zero
    }
  end

  def build(:pro) do
    %Pro{
      phone: "5551234567"
    }
  end

  def build(:referral) do
    %Referral{
      email: sequence(:email, &"bob+#{&1}@canibuildit.com"),
      code: Tokens.token(6)
    }
  end

  def with_referrer(%Referral{} = referral) do
    %Referral{referral | referrer: build(:user)}
  end

  def with_user(%Pro{} = pro) do
    %Pro{pro | user: build(:user)}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    Repo.insert! build(factory_name, attributes)
  end
end
