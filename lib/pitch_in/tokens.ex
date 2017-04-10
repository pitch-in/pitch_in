defmodule PitchIn.Tokens do
  @moduledoc """
  Generates tokens.
  """

  def token(length \\ 32) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.encode64
    |> binary_part(0, length)
  end
end
