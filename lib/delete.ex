defmodule Mix.Tasks.Husky.Delete do
  use Mix.Task

  def run(args) do
    IO.puts("... running husky delete")
    Mix.shell().info(Enum.join(args, " "))

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
