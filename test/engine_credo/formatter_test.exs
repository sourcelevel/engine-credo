defmodule EngineCredo.FormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "prints issues as JSON separated by \0 and \n" do
    output = capture_io(fn ->
      EngineCredo.Config.read("test/fixtures/project_root")
      |> EngineCredo.Runner.check
      |> EngineCredo.Formatter.print
    end)

    first_issue = ~S({"type":"issue","location":{"path":"test/fixtures/project_root/lib/design_issues.exs","lines":{"end":4,"begin":4}},"description":"Found a TODO tag in a comment: # TODO: issue","check_name":"Elixir.Credo.Check.Design.TagTODO","categories":["design"]})
    second_issue = ~S({"type":"issue","location":{"path":"test/fixtures/project_root/lib/design_issues.exs","lines":{"end":5,"begin":5}},"description":"Found a FIXME tag in a comment: # FIXME: issue","check_name":"Elixir.Credo.Check.Design.TagFIXME","categories":["design"]})

    expected_output = first_issue <> "\0\n" <> second_issue <> "\0\n"

    assert expected_output == output
  end
end
