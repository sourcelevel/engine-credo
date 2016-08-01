defmodule EngineCredo.Issue do
  @moduledoc """
  Code Climate Engine internal representation.

  This struct defines how a Credo issue gets translated into a Code Climate
  issue. Most of the mapping is pretty straightforward.

  Waring: this is a work in progress. Issue categories and extra metadata are
  yet TBD.
  """
  @derive [Poison.Encoder]

  defstruct type: nil,
            check_name: nil,
            description: nil,
            categories: [],
            location: %{}

  def convert(issue) do
    %EngineCredo.Issue{
      type: "issue",
      check_name: issue.check,
      description: issue.message,
      categories: [issue.category],
      location: locations(issue)
    }
  end

  defp locations(%Credo.Issue{column: nil, line_no: line, filename: path}) do
    %{
      path: path,
      lines: %{begin: line, end: line}
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
