defmodule EngineCredo.CLI do
  @moduledoc """
  EngineCredo.CLI is the entrypoint for the code analysis escript.

  A single command line parameter is expected, defining the root directory
  where the source files are located.
  """

  alias EngineCredo.{Config, Runner, Formatter}

  def main(argv) do
    config = apply(Config, :read, Enum.take(argv, 2))

    config
    |> Runner.check
    |> Formatter.print
  rescue
    error ->
      # credo:disable-for-next-line Credo.Check.Warning.IoInspect
      IO.puts(:stderr, Exception.format(:error, error, System.stacktrace()))
      System.halt(1)
  end
end
