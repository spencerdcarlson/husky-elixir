defmodule Husky do
  def main(argv \\ []) do
    # TODO rename this file escript, have the mix task use halt appropriately and get the code form  System.cmd
    {stdout, _} = System.cmd("mix", ["husky.execute" | argv])
    {code, _} = stdout
    |> Integer.parse()
    if code != 0 do
      System.halt(code)
    end
  end
end
