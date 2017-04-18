defmodule PitchIn.Factory do
  @moduledoc """
  Sets up ExMachina factories
  """
  use ExMachina.Ecto, repo: PitchIn.Repo

  alias PitchIn.User
  alias PitchIn.Pro
  alias PitchIn.ForgotPassword

  def user_factory do
    %User{
      name: "Bob D. Builder",
      email: "bob@canibuildit.com",
      email: sequence(:email, &"bob+#{&1}@canibuildit.com"),
      password_hash: Comeonin.Bcrypt.hashpwsalt("Password12"),
    }
  end

  def with_pro(%User{} = user) do
    insert(:pro, user: user)
    user
  end

  def pro_factory do
    %Pro{
      phone: "5551234567"
    }
  end

  def with_user(%Pro{} = pro) do
    insert(:user, pro: pro)
    pro
  end

  def forgot_password_factory do
    %ForgotPassword{
      token: "abc123",
    }
  end

  def with_user(%ForgotPassword{} = forgot_password) do
    insert(:user, forgot_passwords: [forgot_password])
    forgot_password
  end
end
