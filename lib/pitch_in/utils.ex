defmodule PitchIn.Utils do
  @doc """
  Like update_in, but works with structs.
  """
  def update_in_struct(struct, [], f), do: f.(struct)
  def update_in_struct(struct, [key | keys], f) do
    Map.update!(struct, key, &(update_in_struct(&1, keys, f)))
  end
end
