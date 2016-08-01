defmodule EngineCredo.IssueTest do
  use ExUnit.Case

  test "handles columnless (line only) issues" do
    original_issue = %Credo.Issue{column: nil, line_no: 42, filename: "here.ex"}
    expected_issue = %EngineCredo.Issue{
      type: "issue",
      check_name: nil,
      description: nil,
      categories: [nil],
      location: %{
        path: "here.ex",
        lines: %{begin: 42, end: 42}
      }
    }

    converted_issue = EngineCredo.Issue.convert(original_issue)

    assert expected_issue == converted_issue
  end

  test "handles issues with column information" do
    original_issue = %Credo.Issue{column: 10, line_no: 42, filename: "here.ex"}
    expected_issue = %EngineCredo.Issue{
      type: "issue",
      check_name: nil,
      description: nil,
      categories: [nil],
      location: %{
        path: "here.ex",
        positions: %{
          begin: %{line: 42, column: 10},
            end: %{line: 42, column: 10}
        }
      }
    }

    converted_issue = EngineCredo.Issue.convert(original_issue)

    assert expected_issue == converted_issue
  end
end
