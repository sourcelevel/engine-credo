defmodule EngineCredo.Runner do
  @moduledoc """
  Actual checking of the source files. A list of issues found for each file is
  attached, then each issue is later converted from an `Ecto.Issue` to an
  `EngineCredo.Issue` for proper output formatting.
  """

  alias EngineCredo.Issue

  def check({config, source_files}) do
    {checked_source_files, _config} = Credo.Check.Runner.run(source_files, config)

    extract_issues(checked_source_files)
  end

  defp extract_issues(stream) do
    stream
    |> Stream.flat_map(&(&1.issues))
    |> Stream.map(&Issue.convert/1)
  end
end
