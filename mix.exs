defmodule EngineCredo.Mixfile do
  use Mix.Project

  def project do
    [app: :engine_credo,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: escript(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :credo, :poison]]
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
      {:credo, github: "britto/credo", branch: "fix-duplicated-source-files", override: true},
      {:poison, "~> 2.2"}
    ]
  end

  def escript do
    [main_module: EngineCredo.CLI, path: "engine-credo"]
  end
end
