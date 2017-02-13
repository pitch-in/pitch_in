defmodule PitchIn.Answer do
  use PitchIn.Web, :model

  schema "answers" do
    belongs_to :user, PitchIn.User
    belongs_to :ask, PitchIn.Ask
    field :message, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:message])
    |> validate_required([:message])
  end
end
