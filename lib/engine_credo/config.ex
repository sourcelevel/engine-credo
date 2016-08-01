defmodule EngineCredo.Config do
  @moduledoc """
  Utility for loading Credo configuration, provided we have a root path. Then a
  list of valid Elixir files is built for analysis.
  """

  def read(command_line_args) do
    config = parse_config(command_line_args)
    source_files = valid_source_files(config)

    {config, source_files}
  end

  defp parse_config(argv) do
    path = List.first(argv) || "."
    Credo.Config.read_or_default(path)
  end

  defp valid_source_files(config) do
    config
    |> Credo.Sources.find
    |> Enum.filter(&(&1.valid?))
  end
end
