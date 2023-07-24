defmodule MapSchemaValidatorTest do
  use ExUnit.Case
#  doctest MapSchemaValidator

  test "simple validation" do
    schema = %{
      value_number: :number,
      value_float: :float,
      value_integer: :integer,
      value_boolean: :boolean,
      value_string: :string,
      value_one_of: [:string, :number],
      value_list: [:string, :number],
      value_map: %{
        inner_value: :string
      }
    }
    map = %{
      value_number: 1,
      value_float: 1.1,
      value_integer: 1,
      value_boolean: false,
      value_string: "value string",
      value_one_of: "value string",
      value_list: ["value string", 1],
      value_map: %{
        inner_value: "value string"
      }
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "optional value" do
    schema = %{
      key: :number,
      optional?: :string
    }
    map = %{
      key: 1
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "raised failure" do
    schema = %{
      key: :number
    }
    map = %{
      key_invalid: 1
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: key", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "value is a map of keys of specific value" do
    schema = %{
      key: %{
        string: :string
      }
    }
    map = %{
      key: %{
        "key_1" => "value string",
        "key_2" => "value string",
        "key_3" => "value string"
      }
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "list of types" do
    schema = %{
      key: [:number, :string]
    }
    map = %{
      key: 1
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
    map = %{
      key: "value"
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "list of types on list" do
    schema = %{
      key: [:number, :string]
    }
    map = %{
      key: [1, "value"]
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
    map = %{
      key: ["value 1", "value 2"]
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "list of object" do
    schema = %{
      key: [
        %{
          inner_key: [:number, :string]
        }
      ]
    }
    map = %{
      key: [
        %{
          inner_key: "value"
        }
      ]
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  @tag :skip
  test "list of object fails" do
    schema = %{
      key: [
        %{
          inner_key: :string
        }
      ]
    }
    map = %{
      key: [
        %{
          inner_key: "value"
        },
        %{
          inner_key: 1
        }
      ]
    }
    assert_raise MapSchemaValidator.InvalidMapError, "error at: key > inner_key", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "list of multiple object" do
    schema = %{
      key: [
        %{
          inner_key: :number
        },
        %{
          inner_key_2: :string
        }
      ]
    }
    map = %{
      key: [
        %{
          inner_key_2: "value"
        },
        %{
          inner_key: 1
        }
      ]
    }
    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end
end
