defmodule EngineCredo.Mixfile do
  use Mix.Project

  def project do
    [app: :engine_credo,
     version: "0.1.0",
     elixir: "~> 1.5",
     escript: escript(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 1.0"},
      {:poison, "~> 2.2"},
      {:briefly, "~> 0.3", only: :test}
    ]
  end

  def escript do
    [main_module: EngineCredo.CLI, path: "engine-credo"]
  end
end
