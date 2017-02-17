defmodule PitchIn.ContactUs do
  use PitchIn.Web, :model

  schema "contact_us" do
    field :subject, :string
    field :body, :string
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subject, :body])
    |> validate_required([:subject, :body])
  end
end
