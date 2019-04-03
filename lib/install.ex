defmodule Mix.Tasks.Husky.Install do
  use Mix.Task
  require Logger

  @after_compile __MODULE__
  @config "./config/config.exs"
  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
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
  defp escript_path,
    do: "deps/#{Mix.Project.config()[:app]}/#{Mix.Project.config()[:escript][:path]}"

  defp path_to_consumer,
    do: :husky |> Application.get_env(:path_to_consumer, "../../") |> Path.expand()

  defp git_directory, do: Path.join(path_to_consumer(), ".git")
  defp git_hooks_directory, do: Path.join([path_to_consumer(), ".git", "hooks"])

  def __after_compile__(_env, _bytecode) do
    run()
  end

  def run(_args \\ nil) do
    Mix.Task.run("loadconfig", [Path.expand(@config)])
    Mix.shell().info("... running 'husky.install' task")
    create_scripts(@hook_list, git_directory(), git_hooks_directory(), escript_path())
  end

  defp create_scripts(hooks, git_dir, hook_dir, escript) do
    unless File.dir?(git_dir), do: raise RuntimeError, message: ".git directory does not exist. Try running $ git init"
    unless File.dir?(hook_dir), do: File.mkdir!(hook_dir)

    hooks
    |> Stream.map(&Path.join(hook_dir, &1))
    |> Stream.map(&{:script, &1, script(@app, @version, escript)})
    |> Stream.map(&create_script/1)
    |> Enum.to_list()
  end

  defp create_script({:script, path, content}) do
    with {:ok, fd} <- File.open(path, [:write]) do
      try do
        IO.binwrite(fd, content)
        {File.chmod!(path, 0o755), :create_script}
      rescue
        _ -> {:error, :create_script}
      after
        File.close(fd)
      end
    else
      _ -> {:error, :create_script}
    end
  end

  defp script(app_name, app_version, escript_path) do
    """
    #!/usr/bin/env sh
    # #{app_name}
    # #{app_version} #{
      :os.type()
      |> Tuple.to_list()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(fn s -> s <> " " end)
    }

    SCRIPT_PATH=\"#{escript_path}\"
    HOOK_NAME=`basename \"$0\"`
    GIT_PARAMS=\"$*\"

    if [ \"${HUSKY_DEBUG}\" = \"true\" ]; then
      echo \"husky:debug $HOOK_NAME hook started...\"
    fi

    if [ -f $SCRIPT_PATH ]; then
      $SCRIPT_PATH $HOOK_NAME \"$GIT_PARAMS\"
    else
      echo \"Can not find Husky escript. Skipping $HOOK_NAME hook\"
      echo \"You can reinstall husky by running mix husky.install\"
    fi
    """
  end
end
