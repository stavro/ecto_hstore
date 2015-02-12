defmodule Hstorex.Mixfile do
  use Mix.Project

  @version "0.0.2"

  def project do
    [app: :hstorex,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,
     test_paths: ["test"],

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Hstorex",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/stavro/hstorex"]
    ]
  end

  defp description do
    """
    Hstorex adds Postgres Hstore compatibility to Postgrex.
    """
  end

  defp package do
    [contributors: ["Sean Stavropoulos"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/stavro/hstorex"}]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:postgrex, git: "https://github.com/ericmj/postgrex.git"}
    ]
  end
end
