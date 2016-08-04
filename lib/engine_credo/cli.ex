defmodule EngineCredo.CLI do
  @moduledoc """
  EngineCredo.CLI is the entrypoint for the code analysis escript.

  A single command line parameter is expected, defining the root directory
  where the source files are located.
  """

  @source_code_path Application.get_env(:engine_credo, :source_code_path)

  alias EngineCredo.{Config,Runner,Formatter}

  def main([]), do: main([@source_code_path])
  def main(argv) do
    argv
    |> List.first
    |> Config.read
    |> Runner.check
    |> Formatter.print
  end
end
