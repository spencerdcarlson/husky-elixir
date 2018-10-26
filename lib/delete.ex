defmodule Mix.Tasks.Husky.Delete do
  use Mix.Task
  require Logger

  def run(args) do
    Mix.shell().info("... running husky delete")
    Logger.debug("args=#{inspect(args)}")

    Application.get_env(:husky, :hook_list)
    |> delete_project_hook_scripts(Application.get_env(:husky, :git_hooks_location))
  end

  def delete_project_hook_scripts(hooks, location) do
    hooks
    |> Enum.map(fn file -> Path.join(location, file) end)
    |> Enum.map(&File.rm/1)

    File.rmdir(location)
  end
end
