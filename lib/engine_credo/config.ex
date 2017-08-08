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
            credo_config: nil,
            source_files: [],
            invalid_files: []

  def read, do: read(@source_code_path, @engine_config_file)

  def read(source_code_path, engine_config_file) do
    engine_config = read_engine_config(engine_config_file)

    load(source_code_path, engine_config)
  end

  defp load(path, engine_config) do
    execution = build_execution(path, engine_config)

    {source_files, invalid_files} = find_source_files(execution)
    execution = load_inline_configuration(execution, source_files)

    %__MODULE__{
      source_code_path: path,
      source_files: source_files,
      invalid_files: invalid_files,
      credo_config: execution
    }
  end

  defp read_engine_config(engine_config_file) do
    engine_config_file
    |> File.read!
    |> Poison.Parser.parse!
  end

  defp build_execution(path, engine_config) do
    path
    |> read_config_file
    |> create_struct
    |> include_files_from(path, engine_config)
    |> boostrap
  end

  defp read_config_file(path) do
    Credo.ConfigFile.read_or_default(path, nil, true) # true required for safe loading of `.credo.exs`.
  end

  defp create_struct(%Credo.ConfigFile{} = config_file) do
    %Credo.Execution{
      files: config_file.files,
      checks: config_file.checks,
      requires: config_file.requires,
      strict: config_file.strict,
      color: false
    }
  end

  defp include_files_from(execution, path, engine_config) do
    include_paths =
      engine_config["include_paths"]
      |> List.wrap
      |> Enum.map(&Path.join(path, &1))

    update_in execution.files[:included], fn files ->
      files
      |> Enum.concat(include_paths)
      |> Enum.uniq
    end
  end

  # Filter out malformed Elixir files and also valid Elixir files with an unknown
  # file extension (`.ex` or `.exs`).
  defp find_source_files(execution) do
    execution
    |> Credo.Sources.find
    |> Enum.filter(&String.ends_with?(&1.filename, [".ex", ".exs"]))
    |> Enum.split_with(&(&1.valid?))
  end

  # TODO: Remove this once stop supporting the inline attribute configuration.
  def load_inline_configuration(execution, source_files) do
    lint_configuration =
      source_files
      |> Credo.Check.FindLintAttributes.run(execution, [])
      |> Enum.into(%{})

    %Credo.Execution{execution | lint_attribute_map: lint_configuration}
  end

  defp boostrap(execution) do
    execution
    |> Credo.Execution.Issues.start_server
    # TODO: Remove this once stop supporting the inline attribute configuration.
    |> Credo.CLI.Output.UI.use_colors
  end
end
