defmodule PitchIn.UsDate do
  @moduledoc """
  Support passing US-formatted date strings to Timex Ecto.
  Basically just delegates to Timex.Ecto.Date
  """
  use Timex
  alias Timex.Ecto.Date

  @behaviour Ecto.Type

  def type, do: :date

  def cast(date) when is_binary(date) do
    with {:ok, parsed} <- Timex.parse(date, "{D}/{M}/{YYYY}"),
         {:ok, formatted} <- Timex.format(parsed, "{YYYY}-{0M}-{0D}")
    do
      formatted
    else
      {:error, _} -> date
    end
    |> Date.cast
  end
  def cast(date) do
    Date.cast(date)
  end

  def load(data), do: Date.load(data)
  def dump(data), do: Date.dump(data)
  def autogenerate(percision), do: Date.autogenerate(percision)
end
