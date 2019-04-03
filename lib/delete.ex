defmodule Mix.Tasks.Husky.Delete do
  use Mix.Task
  require Logger

  @hook_list [
    "applypatch-msg",
    "pre-applypatch",
    "post-applypatch",
    "pre-commit",
    "prepare-commit-msg",
    "commit-msg",
    "post-commit",
    "pre-rebase",
    "post-checkout",
    "post-merge",
    "pre-push",
    "pre-receive",
    "update",
    "post-receive",
    "post-update",
    "push-to-checkout",
    "pre-auto-gc",
    "post-rewrite",
    "sendemail-validate"
  ]
  @config "./config/config.exs"

  defp path_to_consumer,
       do: :husky |> Application.get_env(:path_to_consumer, "../../") |> Path.expand()

  defp git_hooks_directory, do: Path.join([path_to_consumer(), ".git", "hooks"])

  def run(_args) do
    Mix.shell().info("... running husky delete")
    Mix.Task.run("loadconfig", [Path.expand(@config)])
    delete_scripts(@hook_list, git_hooks_directory())
  end

  def delete_scripts(hooks, location) do
    hooks
    |> Enum.map(&Path.join(location, &1))
    |> Enum.map(&File.rm/1)

    File.rmdir(location)
  end
end
