defmodule PitchIn.Repo.Migrations.UniqueAlerts do
  use Ecto.Migration

  def change do
    create unique_index(
      :search_alerts,
      [constraints],
      name: :unique_alerts
    )

  end

  defp constraints do
    columns = ~w(profession role years_experience issue user_id)
    types = ~w(string string integer string integer)a
    
    columns
    |> Enum.zip(types)
    |> Enum.map(&null_constraint/1)
    |> Enum.join(",")
  end

  defp null_constraint({column, :integer}), do: "coalesce(#{column}, -1)"
  defp null_constraint({column, :string}), do: "coalesce(#{column}, ' ')"
end
