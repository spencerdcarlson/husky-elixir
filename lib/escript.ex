defmodule Husky do
  @moduledoc """
  escript that invokes `mix husky.execute`
  """

  @doc """
  escript entry point. The correct shell exit code is preserved
  """
  def main(argv \\ []) do
    IO.puts("🐶")
    IO.puts(".... running husky hook")
    {stderr_stdout, code} = System.cmd("mix", ["husky.execute" | argv])
    IO.puts(stderr_stdout)
    System.halt(code)
  end
end
