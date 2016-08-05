defmodule EngineCredo.ConfigTest do
  use ExUnit.Case

  alias EngineCredo.Config

  test "configures the credo engine for a given path" do
    %{credo_config: config} = Config.read(%Config{source_code_path: "test/fixtures/project_root"})

    expected_included_paths = [
      "test/fixtures/project_root/lib/**/*.{ex,exs}",
      "test/fixtures/project_root/src",
      "test/fixtures/project_root/web",
      "test/fixtures/project_root/apps"
    ]

    assert expected_included_paths == config.files.included
    assert Enum.member?(config.checks, {Credo.Check.Refactor.ABCSize})
  end

  test "merges paths from the engine config" do
    engine_config = %{
      "include_paths" => [
        "src/",
        "extra/",
        "other/no_issues.exs"
      ]
    }

    %{credo_config: config} = Config.read(%Config{
      source_code_path: "test/fixtures/project_root",
      engine_config: engine_config
    })

    expected_included_paths = [
      "test/fixtures/project_root/lib/**/*.{ex,exs}",
      "test/fixtures/project_root/src",
      "test/fixtures/project_root/web",
      "test/fixtures/project_root/apps",
      "test/fixtures/project_root/extra",
      "test/fixtures/project_root/other/no_issues.exs"
    ]

    assert expected_included_paths == config.files.included
  end

  test "finds elixir files to check" do
    %{source_files: files} = Config.read(%Config{source_code_path: "test/fixtures/project_root"})

    [%Credo.SourceFile{filename: file}] = files
    assert "test/fixtures/project_root/lib/design_issues.exs" == file
  end
end
