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
            source_files: [],
            invalid_files: []

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
      |> Credo.ConfigFile.read_or_default(nil, true) # true required for safe loading of `.credo.exs`
      |> cast_to_config
      |> include_files_from(engine_config, path)
      |> Credo.Execution.SourceFiles.start_server
      |> Credo.Execution.Issues.start_server
      |> Credo.CLI.Output.UI.use_colors

    {source_files, invalid_files} = find_source_files(credo_config)
    Credo.Execution.put_source_files(credo_config, source_files)
    inline_configuration = find_inline_configuration(source_files, credo_config)

    %{config | credo_config: %{credo_config | lint_attribute_map: inline_configuration}, source_files: source_files, invalid_files: invalid_files}
  end

  def read(source_code_path, engine_config_file) do
    engine_config = read_engine_config(engine_config_file)
    read(%__MODULE__{source_code_path: source_code_path, engine_config: engine_config})
  end

  def cast_to_config(%Credo.ConfigFile{} = config_file) do
    %Credo.Execution{
      files: config_file.files,
      checks: config_file.checks,
      requires: config_file.requires,
      strict: config_file.strict,
      color: false,
      check_for_updates: false
    }
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

  # Filter out malformed Elixir files and also valid Elixir files with an unknown
  # file extension (`.ex` or `.exs`).
  defp find_source_files(config) do
    config
    |> Credo.Sources.find
    |> Enum.filter(&String.ends_with?(&1.filename, [".ex", ".exs"]))
    |> Enum.partition(&(&1.valid?))
  end

  defp find_inline_configuration(source_files, credo_config) do
    source_files
    |> Credo.Check.FindLintAttributes.run(credo_config, [])
    |> Enum.into(%{})
  end
end
