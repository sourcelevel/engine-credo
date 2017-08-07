defmodule EngineCredo.Runner do
  @moduledoc """
  Actual checking of the source files. A list of issues found for each file is
  attached, then each issue is later converted from an `Ecto.Issue` to an
  `EngineCredo.Issue` for proper output formatting.
  """

  alias EngineCredo.{Issue,Config}
  alias Credo.CLI.Filter
  alias Credo.Execution

  def check(%Config{credo_config: config, source_files: files, source_code_path: path_prefix}) do
    :ok = Credo.Check.Runner.run(files, config)

    issues = Execution.get_issues(config)

    extract_issues(issues, path_prefix, config)
  end

  defp extract_issues(issues, path_prefix, config) do
    issues
    |> Filter.valid_issues(config)
    |> Enum.map(&Issue.convert(&1, path_prefix))
  end
end
