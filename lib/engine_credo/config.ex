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
            execution: nil,
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

    execution =
      execution
      |> load_comment_configuration(source_files)

    %__MODULE__{
      source_code_path: path,
      source_files: source_files,
      invalid_files: invalid_files,
      execution: execution
    }
  end

  defp read_engine_config(engine_config_file) do
    engine_config_file
    |> File.read!()
    |> Poison.decode!()
  end

  defp build_execution(path, engine_config) do
    path
    |> read_config_file
    |> reject_disabled_checks
    |> create_struct
    |> include_files_from(path, engine_config)
    |> boostrap
  end

  defp read_config_file(path) do
    exec = Credo.Execution.build()
    Credo.Execution.Task.run(Credo.Execution.Task.AppendDefaultConfig, exec)

    # true required for safe loading of `.credo.exs`.
    {:ok, result} = Credo.ConfigFile.read_or_default(exec, path, nil, true)

    result
  end

  defp reject_disabled_checks(engine_config) do
    checks =
      Enum.reject(engine_config.checks, fn
        {_check, false} ->
          true

        {_check} ->
          false

        {_check, _opts} ->
          false
      end)

    %Credo.ConfigFile{engine_config | checks: checks}
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
      |> List.wrap()
      |> Enum.map(&Path.join(path, &1))

    update_in(execution.files[:included], fn files ->
      files
      |> Enum.concat(include_paths)
      |> Enum.uniq()
    end)
  end

  # Filter out malformed Elixir files and also valid Elixir files with an unknown
  # file extension (`.ex` or `.exs`).
  defp find_source_files(execution) do
    execution
    |> Credo.Sources.find()
    |> Enum.filter(&String.ends_with?(&1.filename, [".ex", ".exs"]))
    |> Enum.split_with(fn x -> x.status == :valid end)
  end

  defp load_comment_configuration(execution, source_files) do
    comment_configuration =
      source_files
      |> Credo.Check.ConfigCommentFinder.run(execution, [])
      |> Enum.into(%{})

    %Credo.Execution{execution | config_comment_map: comment_configuration}
  end

  defp boostrap(execution) do
    execution
    |> Credo.Execution.ExecutionIssues.start_server()
    # TODO: Remove this once stop supporting the inline attribute configuration.
    |> Credo.CLI.Output.UI.use_colors()
  end
end
