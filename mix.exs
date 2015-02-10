defmodule Ecto.Hstore.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :ecto_hstore,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     test_paths: ["test"],

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Ecto.Hstore",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/stavro/ecto_hstore"]
    ]
  end

  defp description do
    """
    Ecto.Hstore adds Postgres Hstore compatibility to Ecto.
    """
  end

  defp package do
    [contributors: ["Sean Stavropoulos"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/stavro/ecto_hstore"}]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:ecto, ">= 0.5.0"}]
  end
end
