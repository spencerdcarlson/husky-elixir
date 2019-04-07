defmodule Mix.Tasks.Husky.Delete do
  @moduledoc """
  Mix task to delete husky git-hook scripts. This task also deletes the .git/hooks directory
  """
  use Mix.Task
  require Husky.Util
  alias Husky.Util

  @doc """
  deletes all the git-hook scripts declared in `Husky.Util.hooks/0` and the .git/hooks directory

  ## Examples
  `mix husky.delete`
  """
  def run(_args) do
    Mix.shell().info("... running husky delete")
    Mix.Task.run("loadconfig", [Util.config_path()])
    delete_scripts(Util.hooks(), Util.git_hooks_directory())
  end

  defp delete_scripts(hooks, location) do
    hooks
    |> Stream.map(&Path.join(location, &1))
    |> Enum.each(&File.rm/1)

    File.rmdir(location)
  end
end
