defmodule MapSchemaValidatorTest do
  use ExUnit.Case
  doctest MapSchemaValidator

  test "simple validation" do
    schema = %{
      key: :number
    }
    map = %{
      key: 1
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end
end
