defmodule Husky do
  def main(argv \\ []) do
    {_, code} = System.cmd("mix", ["husky.execute" | argv])
    System.halt(code)
  end
end
