defmodule EngineCredo.Issue do
  @moduledoc """
  Code Climate Engine internal representation.

  This struct defines how a Credo issue gets translated into a Code Climate
  issue. Most of the mapping is pretty straightforward.
  """

  @derive [Poison.Encoder]

  @remediation_points %{
    "Bug Risk" => 100_000,
    "Clarity" => 50_000,
    "Compatibility" => 50_000,
    "Complexity" => 100_000,
    "Duplication" => 100_000,
    "Performance" => 50_000,
    "Security" => 100_000,
    "Style" => 50_000,
  }

  defstruct type: nil,
            check_name: nil,
            description: nil,
            remediation_points: nil,
            categories: [],
            location: %{}

  @doc """
  Converts a `Credo.Issue` into an `EngineCredo.Issue`.

  An optional `path_prefix` can be provided, so that all the paths converted
  are relative to the given prefix.
  """
  def convert(issue, path_prefix \\ "") do
    issue = update_in(issue.filename, &Path.relative_to(&1, path_prefix))
    category = EngineCredo.IssueCategories.for_check(issue.check)

    %EngineCredo.Issue{
      type: "issue",
      check_name: issue.check,
      description: issue.message,
      remediation_points: @remediation_points[category],
      categories: [category],
      location: locations(issue)
    }
  end

  defp locations(%Credo.Issue{column: nil, line_no: line, filename: path}) do
    %{
      path: path,
      lines: %{begin: line || 1, end: line || 1}
    }
  end

  defp locations(%Credo.Issue{column: column, line_no: line, filename: path}) do
    %{
      path: path,
      positions: %{
        begin: %{line: line, column: column},
          end: %{line: line, column: column}
      }
    }
  end
end
