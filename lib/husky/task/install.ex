defmodule Mix.Tasks.Husky.Install do
  @moduledoc """
  Mix task to install all git-hook scripts.
  """

  use Mix.Task
  require Husky.Util
  alias Husky.{Script, Util}

  @after_compile __MODULE__
  @doc """
  Install all scripts to `Husky.Util.git_hooks_directory/0` after compile.

  ## Examples
  `mix compile`
  """
  def __after_compile__(_env, _bytecode) do
    run()
  end

  @doc """
  mix task to install git-hook scripts

  ## Examples
  `mix husky.install`
  """
  def run(_args \\ nil) do
    Mix.Task.run("loadconfig", [Util.config_path()])
    Mix.shell().info("... running 'husky.install' task")
    create_scripts(Util.hooks(), Util.git_hooks_directory())
  end

  defp create_scripts(hooks, dir) do
    unless File.dir?(Path.dirname(dir)),
      do: raise(RuntimeError, message: ".git directory does not exist. Try running $ git init")

    unless File.dir?(dir), do: File.mkdir!(dir)

    error_count =
      hooks
      |> Stream.map(&Script.new/1)
      |> Stream.map(&Script.add_content/1)
      |> Stream.map(&create_script/1)
      |> Enum.to_list()
      |> Enum.filter(&(elem(&1, 0) == :error))
      |> length()

    if error_count == 0 do
      Mix.shell().info("successfully installed husky scripts")
      {:ok, :install}
    else
      Mix.shell().error("could not create #{error_count} script(s)")
      {:error, :install}
    end
  end

  defp create_script(%Script{path: path, content: content})
       when is_binary(path) and is_binary(content) do
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

  defp create_script(_), do: {:error, :create_script}
end
