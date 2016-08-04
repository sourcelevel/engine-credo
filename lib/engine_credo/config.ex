defmodule EngineCredo.Config do
  @moduledoc """
  Utility for loading Credo configuration, provided we have a root path. Then a
  list of valid Elixir files is built for analysis.

  Additional configuration is provided by the Code Climate engine config, which
  is a JSON file (`/config.json`) residing at the container root by default.
  """

  @engine_config_file Application.get_env(:engine_credo, :engine_config_file)

  def read(source_path, engine_config_file \\ @engine_config_file) do
    engine_config = read_engine_config(engine_config_file)

    credo_config =
      source_path
      |> Credo.Config.read_or_default
      |> include_files_from(engine_config, source_path)

    source_files = valid_source_files(credo_config)

    {credo_config, source_files}
  end

  defp valid_source_files(config) do
    config
    |> Credo.Sources.find
    |> Enum.filter(&(&1.valid?))
  end

  defp read_engine_config(config_file) do
    config_file
    |> File.read!
    |> Poison.Parser.parse!
  end

  defp include_files_from(config, engine_config, source_path) do
    files_from_engine_config =
      engine_config["include_paths"]
      |> List.wrap
      |> Enum.map(&Path.join(source_path, &1))

    update_in config.files[:included], fn files ->
      files
      |> Enum.concat(files_from_engine_config)
      |> Enum.uniq
    end
  end
end
