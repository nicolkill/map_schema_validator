defmodule MapSchemaValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :map_schema_validator,
      version: "0.1.7",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "map_schema_validator",
      description: "Map/JSON format verifier, verify if keys/values exists.",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      source_url: "https://github.com/nicolkill/map_schema_validator",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "map_schema_validator",
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/nicolkill/map_schema_validator"},
    ]
  end
end
