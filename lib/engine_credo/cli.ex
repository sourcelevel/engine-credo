defmodule EngineCredo.CLI do
  @moduledoc """
  EngineCredo.CLI is the entrypoint for the code analysis escript.

  A single command line parameter is expected, defining the root directory
  where the source files are located.
  """

  alias EngineCredo.{Config, Runner, Formatter}

  @lint {~r/Inspect/, false}
  def main(argv) do
    config = apply(Config, :read, Enum.take(argv, 2))

    config
    |> Runner.check
    |> Formatter.print
  rescue
    error ->
      IO.puts(:stderr, Exception.format(:error, error))
      System.halt(1)
  end
end
