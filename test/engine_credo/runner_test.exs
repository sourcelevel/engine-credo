defmodule EngineCredo.RunnerTest do
  use ExUnit.Case

  test "finds credo issues for the given source files" do
    checked_files = EngineCredo.Config.read(["test/fixtures/project_root"])
                    |> EngineCredo.Runner.check
                    |> Enum.to_list

    issues = checked_files |> Enum.map(&(&1.check_name))

    assert [Credo.Check.Design.TagTODO, Credo.Check.Design.TagFIXME] == issues
  end
end
