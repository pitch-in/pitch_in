defmodule PitchIn.Web.ContactUs do
  use PitchIn.Web, :model

  schema "contact_us" do
    field :subject, :string
    field :body, :string
    field :email, :string
    field :name, :string
    field :from_page, :string
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject, :body, :email, :name, :from_page])
    |> validate_required([:subject, :body, :name, :email])
  end
end
