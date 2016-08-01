defmodule EngineCredo.CLI do
  @moduledoc """
  EngineCredo.CLI is the entrypoint for the code analysis escript.

  A single command line parameter is expected, defining the root directory
  where the source files are located.
  """

  alias EngineCredo.{Config,Runner,Formatter}

  def main(argv) do
    argv
    |> Config.read
    |> Runner.check
    |> Formatter.print
  end
end
