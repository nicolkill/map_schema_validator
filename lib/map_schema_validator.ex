defmodule MapSchemaValidator do
  @moduledoc """
  It's a map format verifier, verify if keys/values exist in a given map, short and quick, you can specify more than one
  format and verify list of values.

  Just use the function [`MapSchemaValidator.validate/2`](https://hexdocs.pm) or [`MapSchemaValidator.validate!/2`](https://hexdocs.pm)
  """

  defmodule InvalidMapError do
    defexception message: "default message"
  end

  alias MapSchemaValidator.MapUtils
  alias MapSchemaValidator.ValueValidator

  defp params(key) do
    key_string = to_string(key)

    mandatory =
      key_string
      |> String.contains?("?")
      |> Kernel.!()

    key_string = String.replace(key_string, "?", "")
    {mandatory, String.to_atom(key_string)}
  end

  @spec iterate([atom()], map(), map(), [String.t()]) :: bool()
  defp iterate([], _schema, _json, _steps), do: true

  defp iterate([key | rest], schema, json, steps) do
    {mandatory, key_core} = params(key)
    schema_value = Map.get(schema, key)
    json_value = Map.get(json, key_core)
    exist_in_json? = Map.has_key?(json, key_core)
    key_is_value? = ValueValidator.is_valid_value?(key)

    next =
      case {key_is_value?, exist_in_json?} do
        {true, false} ->
          json
          |> Map.keys()
          |> Enum.reduce(
            true,
            &(&2 and ValueValidator.validate_values(key, to_string(&1), steps) and
                ValueValidator.validate_values(key, Map.get(json, &1), steps))
          )

        {_, true} ->
          ValueValidator.validate_values(schema_value, json_value, steps ++ [key_core])

        _ ->
          !mandatory
      end

    if next do
      iterate(rest, schema, json, steps)
    else
      raise InvalidMapError, message: "error at: #{Enum.join(steps ++ [key_core], " -> ")}"
    end
  end

  def validate_json!(schema, json, steps \\ []) do
    schema_keys = Map.keys(schema)

    corrected_schema = MapUtils.map_to_atom_keys(schema)
    corrected_json = MapUtils.map_to_atom_keys(json)

    iterate(schema_keys, corrected_schema, corrected_json, steps)
  end

  @doc """
  By param schema validates the param data and compares the format and values to ensure follows a specific format.

  ## Examples

      iex> MapSchemaValidator.validate(%{key: :string}, %{key: "value"})
      {:ok, nil}

      iex> MapSchemaValidator.validate(%{key: [:string, :number]}, %{key: 1})
      {:ok, nil}

      iex> MapSchemaValidator.validate(%{key: [%{inner_key: :string}]}, %{key: [%{inner_key: "value_1"}, %{inner_key: "value_2"}]})
      {:ok, nil}

      iex> MapSchemaValidator.validate(%{key: [%{inner_key: :string}]}, %{key: [%{inner_key: 1}, %{inner_key: "value_2"}]})
      {:error, %MapSchemaValidator.InvalidMapError{message: "error at: key -> inner_key"}}

  """
  @spec validate(map(), map()) :: {:ok | :error, any()}
  def validate(schema, json) do
    validate_json!(schema, json)
    {:ok, nil}
  rescue
    e in InvalidMapError ->
      {:error, e}
  end

  @doc """
  Same as MapSchemaValidator.validate/2 but raises in fail.

  ## Examples

      iex> MapSchemaValidator.validate!(%{key: :string}, %{key: "value"})
      :ok

      iex> MapSchemaValidator.validate!(%{key: [:string, :number]}, %{key: 1})
      :ok

      iex> MapSchemaValidator.validate!(%{key: [%{inner_key: :string}]}, %{key: [%{inner_key: "value_1"}, %{inner_key: "value_2"}]})
      :ok

      iex> MapSchemaValidator.validate!(%{key: [%{inner_key: :string}]}, %{key: [%{inner_key: 1}, %{inner_key: "value_2"}]})
      ** (MapSchemaValidator.InvalidMapError) error at: key -> inner_key
  """
  @spec validate!(map(), map()) :: :ok
  def validate!(schema, json) do
    validate_json!(schema, json)
    :ok
  end
end
