defmodule EngineCredo.Formatter do
  @moduledoc """
  Code Climate Engine compatible formatting.

  The engine expects a stream of issues formatted as JSON. One per line, with
  an additional `\0` character as separator.
  """
  alias EngineCredo.Config

  def print(stream) do
    stream
    |> encode
    |> Stream.each(&print_issue/1)
    |> Stream.run
  end

  def error(%Config{invalid_files: files}) do
    Enum.each(files, &print_error/1)
  end

  defp encode(stream) do
    Stream.map(stream, &Poison.encode!/1)
  end

  defp print_issue(issue) do
    IO.write(issue)
    IO.write("\0\n")
  end

  defp print_error(file) do
    IO.write(:stderr, "Invalid file detected #{file.filename}\n")
  end
end
