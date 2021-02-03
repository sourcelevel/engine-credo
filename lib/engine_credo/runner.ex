defmodule EngineCredo.Runner do
  @moduledoc """
  Actual checking of the source files. A list of issues found for each file is
  attached, then each issue is later converted from an `Ecto.Issue` to an
  `EngineCredo.Issue` for proper output formatting.
  """

  alias EngineCredo.{Issue, Config}
  alias Credo.CLI.Filter
  alias Credo.Execution

  def check(%Config{execution: execution, source_files: files, source_code_path: path_prefix}) do
    Execution.put_source_files(execution, files)

    :ok = Credo.Check.Runner.run(files, execution)

    issues = Execution.get_issues(execution)

    extract_issues(issues, path_prefix, execution)
  end

  defp extract_issues(issues, path_prefix, execution) do
    issues
    |> Filter.valid_issues(execution)
    |> Enum.map(&Issue.convert(&1, path_prefix))
  end
end
