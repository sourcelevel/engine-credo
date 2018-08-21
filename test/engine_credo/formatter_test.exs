defmodule EngineCredo.FormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias EngineCredo.{Config, Formatter, Runner}

  test "prints issues as JSON separated by \\0 and \\n" do
    output = capture_io(fn ->
      Config.read
      |> Runner.check
      |> Formatter.print
    end)

    issues = [
      ~S({"type":"issue","remediation_points":100000,"location":{"path":"lib/design_issues.exs","lines":{"end":5,"begin":5}},"description":"Found a FIXME tag in a comment: # FIXME: issue","check_name":"Elixir.Credo.Check.Design.TagFIXME","categories":["Bug Risk"]}),
      ~S({"type":"issue","remediation_points":100000,"location":{"path":"lib/design_issues.exs","lines":{"end":4,"begin":4}},"description":"Found a TODO tag in a comment: # TODO: issue","check_name":"Elixir.Credo.Check.Design.TagTODO","categories":["Bug Risk"]}),
      ~S({"type":"issue","remediation_points":100000,"location":{"path":"lib/ignore_via_attribute.exs","lines":{"end":6,"begin":6}},"description":"Found a TODO tag in a comment: # TODO: This TODO should not be reported","check_name":"Elixir.Credo.Check.Design.TagTODO","categories":["Bug Risk"]})
    ]

    expected_output = Enum.join(issues, "\0\n") <> "\0\n"

    assert expected_output == output
  end

  test "prints a warning for each invalid source file detected" do
    output = capture_io(:stderr, fn ->
      Formatter.error(Config.read)
    end)

    first_error = "Invalid file detected test/fixtures/project_root/lib/invalid_elixir.exs\n"
    second_error = "Invalid file detected test/fixtures/project_root/lib/non_utf8.exs\n"
    expected_output = first_error <> second_error

    assert String.contains?(output, expected_output)
  end
end
