defmodule Galois.MixProject do
  use Mix.Project

  def project do
    [
      app: :galois,
      description: "Galois Finite Field Arithmetic",
      version: "0.0.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package() do
    [
      name: "galois",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["0BSD"],
      links: %{"GitHub" => "https://github.com/jnnks/galois"}
    ]
  end
end
