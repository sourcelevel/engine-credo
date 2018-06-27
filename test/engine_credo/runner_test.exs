defmodule EngineCredo.RunnerTest do
  use ExUnit.Case

  alias EngineCredo.{Config, Runner}

  test "finds credo issues for the given source files" do
    checked_files =
      Config.read
      |> Runner.check
      |> Enum.to_list

    issues = Enum.map(checked_files, &(&1.check_name))

    assert [Credo.Check.Design.TagTODO, Credo.Check.Design.TagFIXME, Credo.Check.Design.TagTODO] == issues
  end
end
