defmodule EngineCredo.ConfigTest do
  use ExUnit.Case

  alias EngineCredo.Config

  test "configures the credo engine for a given path" do
    %{credo_config: config} = Config.read

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

    %{credo_config: config} = Config.read(%Config{engine_config: engine_config})

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
    %{source_files: files} = Config.read

    found_files = [
      "test/fixtures/project_root/lib/design_issues.exs",
      "test/fixtures/project_root/lib/ignore_via_attribute.exs"
    ]

    assert found_files == Enum.map(files, &(&1.filename))
  end

  test "finds elixir that are not valid to check" do
    %{invalid_files: files} = Config.read

    expected_invalid_files = [
      "test/fixtures/project_root/lib/invalid_elixir.exs",
      "test/fixtures/project_root/lib/non_utf8.exs"
    ]

    assert expected_invalid_files == Enum.map(files, &(&1.filename))
  end

  test "filters out valid files with unknown extensions" do
    engine_config = %{
      "include_paths" => ["valid_elixir_invalid_extension.txt"]
    }

    %{source_files: files} = Config.read(%Config{engine_config: engine_config})

    contains_invalid_file = Enum.any?(files,
      &(&1.filename == "test/fixtures/project_root/valid_elixir_invalid_extension.txt")
    )

    refute contains_invalid_file
  end
end
