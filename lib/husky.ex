defmodule Husky do
  def main(argv \\ []) do
    {stdout, _} = System.cmd("mix", ["husky.execute" | argv])
    {code, _} = stdout
    |> Integer.parse()
    if code != 0 do
      System.halt(code)
    end
  end
end
