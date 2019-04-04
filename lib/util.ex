defmodule Husky.Util do
  use Constants
  define(version, Mix.Project.config()[:version])
  define(app, Mix.Project.config()[:app])
  define(config_path, Path.expand("./config/config.exs"))

  define(hooks, [
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
  ])

  def path_to_consumer do
    :husky
    |> Application.get_env(:path_to_consumer, "../../")
    |> Path.expand()
  end

  def escript_path do
    Application.get_env(
      :husky,
      :escript_path,
      "deps/#{Mix.Project.config()[:app]}/#{Mix.Project.config()[:escript][:path]}"
    )
  end

  def git_hooks_directory do
    Path.join([path_to_consumer(), ".git", "hooks"])
  end
end
