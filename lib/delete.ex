defmodule Mix.Tasks.Husky.Delete do
  use Mix.Task
  require Logger
  require Husky.Util
  alias Husky.Util

  def run(_args) do
    Mix.shell().info("... running husky delete")
    Mix.Task.run("loadconfig", [Util.config_path()])
    delete_scripts(Util.hooks(), Util.git_hooks_directory())
  end

  def delete_scripts(hooks, location) do
    hooks
    |> Enum.map(&Path.join(location, &1))
    |> Enum.map(&File.rm/1)

    File.rmdir(location)
  end
end
