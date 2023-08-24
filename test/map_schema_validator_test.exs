defmodule MapSchemaValidatorTest do
  use ExUnit.Case
  doctest MapSchemaValidator

  test "simple validation" do
    schema = %{
      value_number: :number,
      value_float: :float,
      value_integer: :integer,
      value_boolean: :boolean,
      value_string: :string,
      uuid: :uuid,
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
      uuid: "fcfe5f21-8a08-4c9a-9f97-29d2fd6a27b9",
      value_one_of: "value string",
      value_list: ["value string", 1],
      value_map: %{
        inner_value: "value string"
      }
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "raise when missing mandatory value" do
    schema = %{
      key: :number,
      not_optional: :string
    }

    map = %{
      key: 1
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: not_optional", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
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

  test "raised failure on invalid key" do
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

  test "raised failure on invalid value" do
    schema = %{
      key: :number
    }

    map = %{
      key: "value"
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

  test "list of object fails" do
    schema = %{
      key: [
        %{
          inner_key: :string,
          inner_key_number: :number
        }
      ]
    }

    map = %{
      key: [
        %{
          inner_key: "value",
          inner_key_number: 1
        },
        %{
          inner_key: "value",
          inner_key_number: "value"
        }
      ]
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: key -> inner_key_number", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "list of object with nested list of objects fails" do
    schema = %{
      key: [
        %{
          inner_key: :string,
          inner_key_list: [
            %{
              inner_nested_value: :string
            }
          ]
        }
      ]
    }

    map = %{
      key: [
        %{
          inner_key: "value string",
          inner_key_list: [
            %{
              inner_nested_value: 1
            }
          ]
        }
      ]
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: key -> inner_key_list -> inner_nested_value", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  @tag :skip
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

  @tag :skip
  test "list of multiple object failure" do
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
          inner_key_2: 1
        },
        %{
          inner_key: "value"
        }
      ]
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: key -> inner_key", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "test from readme example" do
    schema = %{
      list: [
        %{
          inner_field: [:string, :number],
          inner_list: [
            %{
              inner_leven_2_flag: [:boolean, :integer]
            }
          ],
          inner_optional_flag?: :boolean
        }
      ]
    }

    map = %{
      list: [
        %{
          inner_field: "value string",
          inner_list: [
            %{
              inner_leven_2_flag: true
            }
          ],
          inner_optional_flag: false
        },
        %{
          inner_field: 10,
          inner_list: [
            %{
              inner_leven_2_flag: true
            }
          ]
        }
      ]
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with naive datetime as string" do
    schema = %{
      datetime: :datetime
    }

    map = %{
      datetime: "2015-01-23 23:50:07"
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with naive datetime" do
    schema = %{
      datetime: :datetime
    }

    map = %{
      datetime: ~N[2015-01-23 23:50:07]
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with invalid naive datetime" do
    schema = %{
      datetime: :datetime
    }

    map = %{
      datetime: "2015-01-23"
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: datetime", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "testing with date as string" do
    schema = %{
      date: :date
    }

    map = %{
      date: "2015-01-23"
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with date" do
    schema = %{
      date: :date
    }

    map = %{
      date: ~D[2015-01-23]
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with invalid date" do
    schema = %{
      date: :date
    }

    map = %{
      date: "23:50:07"
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: date", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "testing with time as string" do
    schema = %{
      time: :time
    }

    map = %{
      time: "23:50:07"
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with time" do
    schema = %{
      time: :time
    }

    map = %{
      time: ~T[23:50:07]
    }

    assert {:ok, _} = MapSchemaValidator.validate(schema, map)
  end

  test "testing with invalid time" do
    schema = %{
      time: :time
    }

    map = %{
      time: "2015-01-23"
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: time", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end

  test "testing with invalid uuid" do
    schema = %{
      uuid: :uuid
    }

    map = %{
      uuid: "fcfe5f21-8a08-4c9a-9f97"
    }

    assert_raise MapSchemaValidator.InvalidMapError, "error at: uuid", fn ->
      MapSchemaValidator.validate!(schema, map)
    end
  end
end
