defmodule Husky.TestHelper do
  alias Husky.Util

  def initialize_empty_git_hook_directory(dir \\ Util.git_hooks_directory()) do
    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.map(&Path.expand(&1, dir))
        |> Enum.each(&File.rm/1)

      {:error, :enoent} ->
        "cd #{Path.expand("../../", dir)} && git init && rm .git/hooks/*"
        |> to_charlist()
        |> :os.cmd()
    end
  end
end

ExUnit.start()
