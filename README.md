# MapSchemaValidator

It's a map format verifier, verify if keys/values exist in a given map, short and quick, you can specify more than one 
format and verify list of values.

The motivation of create this library was verify that a json file content has a specific format and fail in case that 
not matches raises an error with the route to the invalid field

[Docs here!](https://hexdocs.pm/map_schema_validator)

## Installation

If [available in Hex](https://hex.pm/packages/map_schema_validator/0.1.4), the package can be installed
by adding `map_schema_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:map_schema_validator, "~> 0.1.4"}
  ]
end
```

## Usage

Just use the function [`MapSchemaValidator.validate/2`](https://hexdocs.pm/map_schema_validator/0.1.4/MapSchemaValidator.html#validate/2) 
or [`MapSchemaValidator.validate!/2`](https://hexdocs.pm/map_schema_validator/0.1.4/MapSchemaValidator.html#validate!/2)

#### Basic

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
