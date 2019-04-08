defmodule Husky.TestHelper do
  alias Husky.Util

  def rm_files(dir \\ Util.git_hooks_directory()) do
    dir
    |> File.ls!()
    |> Enum.map(&Path.expand(&1, dir))
    |> Enum.each(&File.rm/1)
  end
end

ExUnit.start()
