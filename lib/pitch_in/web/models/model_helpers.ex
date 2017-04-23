defmodule PitchIn.Web.ModelHelpers do
  import Ecto.Changeset

  def validate_email(changeset, key \\ :email) do
    changeset
    |> validate_format(
      key,
      ~r/@/,
      message: "this doesn't look like an email address"
    )
  end

  def validate_url(changeset, key) do
    changeset
    |> validate_format(
      key,
      ~r/^https?:\/\/\S+\.\S+/,
      message: "this doesn't look like a URL. Make sure it starts with http:// or https://"
    )
  end

  def validate_zip(changeset, key) do
    changeset
    |> validate_format(
      key,
      ~r/^\d{5}(-\d{4})?$/,
      message: "this doesn't look like a zip code"
    )
  end

  def validate_one_word(changeset, key) do
    changeset
    |> validate_format(
      key,
      ~r/^\S+$/
    )
  end
end
