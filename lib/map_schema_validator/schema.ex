defmodule MapSchemaValidator.Schema do
  @moduledoc """
  This module it's for create modules that contains all the logic for schema creation
  """

  alias MapSchemaValidator.ValueValidator

  defmacro __using__(_) do
    quote do
      import MapSchemaValidator.Schema

      defp process_type(t) when is_list(t) do
        Enum.map(t, &process_type/1)
      end

      defp process_type(t) do
        case ValueValidator.is_valid_value?(t) do
          true ->
            t

          _ ->
            try do
              inner_schema = apply(t, :schema, [])
            rescue
              _ ->
                raise ArgumentError,
                  message: "field #{t} not uses the MapSchemaValidator.Schema module"
            end
        end
      end

      def schema() do
        fields()
        |> Enum.reduce(%{}, fn {f, t}, acc ->
          Map.put(acc, f, process_type(t))
        end)
      end

      @doc """
      By param schema validates the param data and compares the format and values to ensure follows a specific format.

      ## Examples

          iex> #{unquote(__MODULE__)}.validate(%{key: "value"})
          {:ok, nil}

          iex> #{unquote(__MODULE__)}.validate(%{key: 1})
          {:ok, nil}

          iex> #{unquote(__MODULE__)}.validate( %{key: [%{inner_key: "value_1"}, %{inner_key: "value_2"}]})
          {:ok, nil}

          iex> #{unquote(__MODULE__)}.validate(%{key: [%{inner_key: 1}, %{inner_key: "value_2"}]})
          {:error, %MapSchemaValidator.InvalidMapError{message: "error at: key -> inner_key"}}

      """
      @spec validate(map()) :: {:ok | :error, any()}
      def validate(json) do
        schema()
        |> MapSchemaValidator.validate_json!(json)

        {:ok, nil}
      rescue
        e in MapSchemaValidator.InvalidMapError ->
          {:error, e}
      end

      @doc """
      Same as #{unquote(__MODULE__)}.validate/1 but raises in fail.

      ## Examples

          iex> #{unquote(__MODULE__)}.validate!(%{key: "value"})
          :ok

          iex> #{unquote(__MODULE__)}.validate!(%{key: 1})
          :ok

          iex> #{unquote(__MODULE__)}.validate!(%{key: [%{inner_key: "value_1"}, %{inner_key: "value_2"}]})
          :ok

          iex> #{unquote(__MODULE__)}.validate!(%{key: [%{inner_key: 1}, %{inner_key: "value_2"}]})
          ** (MapSchemaValidator.InvalidMapError) error at: key -> inner_key
      """
      @spec validate!(map()) :: :ok
      def validate!(json) do
        schema()
        |> MapSchemaValidator.validate_json!(json)

        :ok
      end

      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      @before_compile MapSchemaValidator.Schema
    end
  end

  defmacro __before_compile__(env) do
    fields =
      env.module
      |> Module.get_attribute(:fields)

    quote do
      def fields(), do: unquote(fields)
    end
  end

  @doc """
  To add field property with value type to schema
  """
  defmacro field(field, type) do
    quote do
      @fields {unquote(field), unquote(type)}
    end
  end
end
