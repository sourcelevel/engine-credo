defmodule EngineCredo.FormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EngineCredo.{Config,Formatter,Runner}

  test "prints issues as JSON separated by \\0 and \\n" do
    output = capture_io(fn ->
      Config.read
      |> Runner.check
      |> Formatter.print
    end)

    first_issue = ~S({"type":"issue","remediation_points":100000,"location":{"path":"lib/design_issues.exs","lines":{"end":4,"begin":4}},"description":"Found a TODO tag in a comment: # TODO: issue","check_name":"Elixir.Credo.Check.Design.TagTODO","categories":["Bug Risk"]})
    second_issue = ~S({"type":"issue","remediation_points":100000,"location":{"path":"lib/design_issues.exs","lines":{"end":5,"begin":5}},"description":"Found a FIXME tag in a comment: # FIXME: issue","check_name":"Elixir.Credo.Check.Design.TagFIXME","categories":["Bug Risk"]})

    expected_output = first_issue <> "\0\n" <> second_issue <> "\0\n"

    assert expected_output == output
  end

  test "prints a warning for each invalid source file detected" do
    output = capture_io(:stderr, fn ->
      Config.read
      |> Formatter.error
    end)

    first_error = "Invalid file detected test/fixtures/project_root/lib/invalid_elixir.exs\n"
    second_error = "Invalid file detected test/fixtures/project_root/lib/non_utf8.exs\n"
    expected_output = first_error <> second_error

    assert expected_output == output
  end
end
