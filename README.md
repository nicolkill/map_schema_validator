# map_schema_validator

It's a map format verifier, verify if keys/values exist in a given map, short and quick, you can specify more than one 
format and verify list of values.

The motivation of create this library was verify that a json file content has a specific format and fail in case that 
not matches raises an error with the route to the invalid field

[Docs here!](https://hexdocs.pm/map_schema_validator)

## Installation

If [available in Hex](https://hex.pm/packages/map_schema_validator/0.1.6), the package can be installed
by adding `map_schema_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:map_schema_validator, "~> 0.1.6"}
  ]
end
```

## Usage

Just use the function [`MapSchemaValidator.validate/2`](https://hexdocs.pm/map_schema_validator/0.1.6/MapSchemaValidator.html#validate/2) 
or [`MapSchemaValidator.validate!/2`](https://hexdocs.pm/map_schema_validator/0.1.6/MapSchemaValidator.html#validate!/2)

#### Basic usage

```elixir
schema = %{
  field: %{
    inner_field: :string
  }
}
map = %{
  field: %{
    inner_field: "value"
  }
}

case MapSchemaValidator.validate(schema, map) do
  {:ok, _} ->
    :ok
    # your stuff
  {:error, %MapSchemaValidator.InvalidMapError{message: message}} ->
    :error
    # failure
end

try do
  :ok = MapSchemaValidator.validate!(schema, map)
rescue
  e in MapSchemaValidator.InvalidMapError -> 
    e.message
end
```

#### Possible values

You can check inner list of maps or even list of possible values, or even optional values using `?` at the end of the
field name in the schema

```
:float, :integer, :number, :boolean, :string, [:list], %{type: :map}, [%{type: :map}]
```

> the list of maps `[%{type: :map}]` are just valid with one object schema, in this case you are validating that an list
> has the format of the map, but only it's supported one element, multiple object schema options are in backlog

**Primitive types**

```elixir
schema = %{
  value_number: :number,
  value_float: :float,
  value_integer: :integer,
  value_boolean: :boolean,
  value_string: :string
}
map = %{
  value_number: 1,
  value_float: 1.1,
  value_integer: 1,
  value_boolean: false,
  value_string: "value string"
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

**Optional keys**

```elixir
schema = %{
  mandatory_value: :string,
  optional_value?: :number
}
map = %{
  mandatory_value: "value string"
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

> Just adding the `?` char at the end of the key (like Typescript)

**Nested Maps**

```elixir
schema = %{
  value_map: %{
    inner_map: %{
      inner_value: :string
    }
  }
}
map = %{
  value_map: %{
    inner_map: %{
      inner_value: "value string"
    }
  }
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

**List of allowed values**

```elixir
schema = %{
  value_one_of: [:string, :number],
}
map = %{
  value_one_of: "value string",
}

{:ok, _} = MapSchemaValidator.validate(schema, map)

map = %{
  value_one_of: 100,
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

**List of allowed values and list of values**

```elixir
schema = %{
  value_list: [:string, :number],
}
map = %{
  value_list: ["value string", 1],
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

**List of maps with format**

```elixir
schema = %{
  list: [
    %{
      inner_value: :string,
      inner_map: %{
        inner_value: :string
      },
      inner_list: [
        %{
          inner_value_level_2: :number
        }
      ]
    }  
  ]
}
map = %{
  list: [
    %{
      inner_value: "value string",
      inner_map: %{
        inner_value: "value string"
      },
      inner_list: [
        %{
          inner_value_level_2: 100
        }
      ]
    }  
  ]
}

{:ok, _} = MapSchemaValidator.validate(schema, map)
```

> In this case are allowed just one schema per list, multiple are work in progress

#### Advanced example

```elixir
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

{:ok, _} = MapSchemaValidator.validate(schema, map)
```
