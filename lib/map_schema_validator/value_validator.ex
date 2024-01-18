defmodule MapSchemaValidator.ValueValidator do
  @moduledoc """

  """

  @valid_basic_types [
    :float,
    :integer,
    :number,
    :boolean,
    :string,
    :datetime,
    :date,
    :time,
    :uuid
  ]

  def is_valid_value?(type), do: Enum.member?(@valid_basic_types, type)

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :uuid and is_bitstring(json_value) do
    {:ok, _} = UUID.info(json_value)
    true
  rescue
    _ ->
      false
  end

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :time and is_bitstring(json_value) do
    {:ok, _} = Time.from_iso8601(json_value)
    true
  rescue
    _ ->
      false
  end

  def validate_values(schema_value, %Time{} = _json_value, _steps)
      when schema_value == :time,
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :date and is_bitstring(json_value) do
    {:ok, _} = Date.from_iso8601(json_value)
    true
  rescue
    _ ->
      false
  end

  def validate_values(schema_value, %Date{} = _json_value, _steps)
      when schema_value == :date,
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :datetime and is_bitstring(json_value) do
    {:ok, _} = NaiveDateTime.from_iso8601(json_value)
    true
  rescue
    _ ->
      false
  end

  def validate_values(schema_value, %NaiveDateTime{} = _json_value, _steps)
      when schema_value == :datetime,
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :float and is_float(json_value),
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :integer and is_integer(json_value),
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :number and is_number(json_value),
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :boolean and is_boolean(json_value),
      do: true

  def validate_values(schema_value, json_value, _steps)
      when schema_value == :string and is_bitstring(json_value),
      do: true

  def validate_values(schema_value, json_value, steps)
      when is_list(schema_value) and is_list(json_value),
      do:
        Enum.reduce(json_value, true, fn jv, acc ->
          acc and validate_values(schema_value, jv, steps)
        end)

  # todo: validate multiple schema objects and catch exceptions and try with next schema object
  def validate_values(schema_value, json_value, steps)
      when is_list(schema_value),
      do: Enum.any?(schema_value, &validate_values(&1, json_value, steps))

  def validate_values(schema_value, json_value, steps)
      when is_list(json_value),
      do: Enum.any?(json_value, &validate_values(schema_value, &1, steps))

  def validate_values(schema_value, json_value, steps)
      when is_map(schema_value) and is_map(json_value),
      do: MapSchemaValidator.validate_json!(schema_value, json_value, steps)

  def validate_values(_schema_value, _json_value, _steps), do: false
end
