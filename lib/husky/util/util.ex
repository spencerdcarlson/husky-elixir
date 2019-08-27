defmodule Husky.Util do
  @moduledoc """
  Utility to store global constants
  """

  use Constants

  @doc """
  App version.
  """
  define(version, Mix.Project.config()[:version])

  @doc """
  App name.
  """
  define(app, Mix.Project.config()[:app])

  @doc """
  Path to husky's root elixir config.
  """
  define(config_path, Path.expand("./config/config.exs"))

  @doc """
  List of git-hooks to install and delete.
  ```elixir
  [
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
  ```
  """
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

  @doc """
  Relative location from husky's install location to the client of husky.

  The relative path is expanded using `Path.expand/1`.
  Used to determine the correct location to install and delete script files.

  The value of the relative location can be overridden by setting the `:host_path` application config. The default value is `../../`.
  See `config/test.exs` for an override example
  """
  def host_path do
    :husky
    |> Application.get_env(:host_path, File.cwd!())
    |> Path.expand()
  end

  @doc """
  Path from the client of husky to the escript.

  Defaults to `"deps/husky/priv/husky"`
  """
  def escript_path do
    Application.get_env(
      :husky,
      :escript_path,
      "deps/#{Mix.Project.config()[:app]}/#{Mix.Project.config()[:escript][:path]}"
    )
  end

  @doc """
  Full path to the git-hooks install location.
  """
  def git_hooks_directory do
    Path.join([host_path(), ".git", "hooks"])
  end
end
