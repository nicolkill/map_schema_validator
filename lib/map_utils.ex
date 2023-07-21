defmodule MapSchemaValidator.MapUtils do
  @moduledoc """
  Documentation for `MapSchemaValidator`.
  """

  @doc """
  Transforms maps with key-strings to maps with atom-strings.

  ## Examples

      iex> MapSchemaValidator.MapUtils.map_to_atom_keys(%{"key" => "value"})
      %{key: "value"}

  """
  def map_to_atom_keys(map) when map == %{}, do: %{}

  def map_to_atom_keys(map) do
    keys = Map.keys(map)

    already_atom_keys =
      keys
      |> Enum.at(0)
      |> is_atom()

    if already_atom_keys do
      map
    else
      Enum.reduce(keys, %{}, fn k, acc ->
        value = Map.get(map, k)
        Map.put(acc, String.to_atom(k), value)
      end)
    end
  end
end