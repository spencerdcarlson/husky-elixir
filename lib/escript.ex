defmodule Husky do
  def main(argv \\ []) do
    IO.puts("🐶")
    IO.puts(".... running husky hook")
    {stderr_stdout, code} = System.cmd("mix", ["husky.execute" | argv])
    IO.puts(stderr_stdout)
    System.halt(code)
  end
end
