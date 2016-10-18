defmodule EngineCredo.IssueTest do
  use ExUnit.Case

  alias EngineCredo.Issue

  test "handles columnless (line only) issues" do
    original_issue = %Credo.Issue{column: nil, line_no: 42, filename: "here.ex"}

    %Issue{location: converted_location} = Issue.convert(original_issue)

    assert converted_location == %{
      path: "here.ex",
      lines: %{begin: 42, end: 42}
    }
  end

  test "handles issues without line information" do
    original_issue = %Credo.Issue{column: nil, filename: "file.ex"}

    %Issue{location: converted_location} = Issue.convert(original_issue)

    assert converted_location == %{
      path: "file.ex",
      lines: %{begin: 1, end: 1}
    }
  end

  test "handles issues with column information" do
    original_issue = %Credo.Issue{column: 10, line_no: 42, filename: "here.ex"}

    %Issue{location: converted_location} = Issue.convert(original_issue)

    assert converted_location == %{
      path: "here.ex",
      positions: %{
        begin: %{line: 42, column: 10},
          end: %{line: 42, column: 10}
      }
    }
  end

  test "emits paths relative to the given prefix" do
    original_issue = %Credo.Issue{line_no: 42, filename: "/the/project/lib/module/here.ex"}

    %Issue{location: %{path: converted_path}} = Issue.convert(original_issue, "/the/project")

    assert converted_path == "lib/module/here.ex"
  end
end
