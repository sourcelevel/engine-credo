defmodule EngineCredo.ConfigTest do
  use ExUnit.Case

  alias EngineCredo.Config

  test "configures the credo engine for a given path" do
    %{execution: execution} = Config.read()

    expected_included_paths = [
      "test/fixtures/project_root/lib/**/*.{ex,exs}",
      "test/fixtures/project_root/src",
      "test/fixtures/project_root/test/**/*.{ex,exs}",
      "test/fixtures/project_root/web",
      "test/fixtures/project_root/apps"
    ]

    assert expected_included_paths == execution.files.included
    assert Enum.member?(execution.checks, {Credo.Check.Warning.IExPry})
  end

  test "merges paths from the engine config" do
    config_path =
      write_config(%{
        "include_paths" => [
          "src/",
          "extra/",
          "other/no_issues.exs"
        ]
      })

    %{execution: execution} = Config.read(source_code_path(), config_path)

    expected_included_paths = [
      "test/fixtures/project_root/lib/**/*.{ex,exs}",
      "test/fixtures/project_root/src",
      "test/fixtures/project_root/test/**/*.{ex,exs}",
      "test/fixtures/project_root/web",
      "test/fixtures/project_root/apps",
      "test/fixtures/project_root/extra",
      "test/fixtures/project_root/other/no_issues.exs"
    ]

    assert expected_included_paths == execution.files.included
  end

  test "finds elixir files to check" do
    %{source_files: files} = Config.read()

    found_files = [
      "test/fixtures/project_root/lib/design_issues.exs",
      "test/fixtures/project_root/lib/ignore_via_attribute.exs",
      "test/fixtures/project_root/lib/ignore_via_comment.exs"
    ]

    assert found_files == Enum.map(files, & &1.filename)
  end

  test "finds elixir that are not valid to check" do
    %{invalid_files: files} = Config.read()

    expected_invalid_files = [
      "test/fixtures/project_root/lib/invalid_elixir.exs",
      "test/fixtures/project_root/lib/non_utf8.exs"
    ]

    assert expected_invalid_files == Enum.map(files, & &1.filename)
  end

  test "filters out valid files with unknown extensions" do
    config_path =
      write_config(%{
        "include_paths" => ["valid_elixir_invalid_extension.txt"]
      })

    %{source_files: files} = Config.read(source_code_path(), config_path)

    contains_invalid_file =
      Enum.any?(
        files,
        &(&1.filename == "test/fixtures/project_root/valid_elixir_invalid_extension.txt")
      )

    refute contains_invalid_file
  end

  test "rejects disabled checks" do
    config = Config.read()
    checks = config.execution.checks

    contains_disabled_check =
      Enum.any?(checks, fn tuple -> tuple_size(tuple) == 2 && elem(tuple, 1) == false end)

    refute contains_disabled_check
  end

  defp write_config(config) do
    {:ok, path} = Briefly.create()
    File.write!(path, Poison.encode!(config))
    path
  end

  defp source_code_path, do: Application.get_env(:engine_credo, :source_code_path)
end
