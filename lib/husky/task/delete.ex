defmodule Mix.Tasks.Husky.Delete do
  @moduledoc """
  Mix task to delete husky git-hook scripts. This task also deletes the .git/hooks directory
  """
  use Mix.Task
  require Husky.Util
  alias Husky.Util

  @doc """
  deletes all the git-hook scripts declared in `Husky.Util.hooks/0`

  ## Examples
  `mix husky.delete`
  """
  def run(_args \\ nil) do
    Mix.shell().info("... running husky delete")
    Mix.Task.run("loadconfig", [Util.config_path()])
    delete_scripts(Util.hooks(), Util.git_hooks_directory())
  end

  defp delete_scripts(hooks, location) do
    hooks
    |> Stream.map(&Path.join(location, &1))
    |> Enum.each(&File.rm/1)
  end
end
