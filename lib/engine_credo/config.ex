defmodule EngineCredo.Config do
  @moduledoc """
  Utility for loading Credo configuration, provided we have a root path. Then a
  list of valid Elixir files is built for analysis.

  Additional configuration is provided by the Code Climate engine config, which
  is a JSON file (`/config.json`) residing at the container root by default.
  """

  @source_code_path Application.get_env(:engine_credo, :source_code_path)
  @engine_config_file Application.get_env(:engine_credo, :engine_config_file)

  defstruct source_code_path: nil,
            engine_config: nil,
            credo_config: nil,
            source_files: []

  def read, do: read(%__MODULE__{})

  def read(source_code_path) when is_binary(source_code_path) do
    read(%__MODULE__{source_code_path: source_code_path})
  end

  def read(%__MODULE__{source_code_path: nil} = config) do
    read(%{config | source_code_path: @source_code_path})
  end

  def read(%__MODULE__{engine_config: nil} = config) do
    read(%{config | engine_config: read_engine_config(@engine_config_file)})
  end

  def read(%__MODULE__{source_code_path: path, engine_config: engine_config} = config) do
    credo_config =
      path
      |> Credo.Config.read_or_default
      |> include_files_from(engine_config, path)

    source_files = valid_source_files(credo_config)

    %{config | credo_config: credo_config, source_files: source_files}
  end

  def read(source_code_path, engine_config_file) do
    engine_config = read_engine_config(engine_config_file)
    read(%__MODULE__{source_code_path: source_code_path, engine_config: engine_config})
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

  defp valid_source_files(config) do
    config
    |> Credo.Sources.find
    |> Enum.filter(&(&1.valid?))
  end
end
