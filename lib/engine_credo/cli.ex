defmodule EngineCredo.CLI do
  def main(args) do
    args |> say_hello
  end

  def say_hello([name|_]) do
    IO.puts "Hello, #{name}!"
  end

  def say_hello(_) do
    IO.puts "Hello!"
  end
end
