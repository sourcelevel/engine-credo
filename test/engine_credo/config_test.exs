defmodule EngineCredo.ConfigTest do
  use ExUnit.Case

  test "configures the credo engine for a given path" do
    {config, _} = EngineCredo.Config.read(["test/fixtures/project_root"])

    expected_included_paths = [
      "test/fixtures/project_root/lib/**/*.{ex,exs}",
      "test/fixtures/project_root/src",
      "test/fixtures/project_root/web",
      "test/fixtures/project_root/apps"
    ]

    assert expected_included_paths == config.files.included
    assert Enum.member?(config.checks, {Credo.Check.Refactor.ABCSize})
  end

  test "uses default paths when no path is given" do
    {config, _} = EngineCredo.Config.read([])

    assert ["./lib/**/*.{ex,exs}", "./src", "./web", "./apps"] == config.files.included
  end

  test "finds elixir files to check" do
    {_, source_files} = EngineCredo.Config.read(["test/fixtures/project_root"])

    [%Credo.SourceFile{filename: file}] = source_files
    assert "test/fixtures/project_root/lib/design_issues.exs" == file
  end
end
