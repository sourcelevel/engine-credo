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
      location: %{
        path: issue.filename,
        positions: %{
          begin: %{line: issue.line_no, column: issue.column},
            end: %{line: issue.line_no, column: issue.column}
        }
      }
    }
  end
end
