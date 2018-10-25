 defmodule Mix.Tasks.Husky.Install do
  use Mix.Task

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  # escript location escript will execute the correct git hook
  @script_path "deps/#{Mix.Project.config()[:app]}/#{Mix.Project.config()[:escript][:path]}"


  def run(args) do
    IO.puts("... running husky install")
    Mix.Task.run("loadconfig", ["./deps/husky/config/config.exs"])
    Mix.shell.info Enum.join(args, " ")
    Application.get_env(:husky, :hook_list)
    |> install_project_hook_scripts(Application.get_env(:husky, :git_hooks_location))
#
#    Mix.Task.run("escript.build") # first need to cd in to package, run mix deps.get
  end

  def install_project_hook_scripts(hook_list, install_directory) do
    if not File.dir?(".git") do
      raise RuntimeError, message: ".git directory does not exist. Try running $ git init"
    end

    if not File.dir?(install_directory) do
      File.mkdir!(install_directory)
    end

    hook_list
    |> Enum.map(fn f ->
      path = Path.join(install_directory, f)
      with {:ok, file} <- File.open(path, [:write]) do
        IO.binwrite(file, hook_script_content(@app, @version, @script_path))
        File.chmod(path, 0o755)
        File.close(file)
      end
    end)
  end

  def hook_script_content(app_name, app_version, escript_path) do
    "#!/usr/bin/env sh
# #{app_name}
# #{app_version} #{
      :os.type()
      |> Tuple.to_list()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(fn(s) -> s <> " " end)
    }
SCRIPT_PATH=#{escript_path}
HOOK_NAME=`basename \"$0\"`
GIT_PARAMS=\"$*\"

if [ \"${HUSKY_DEBUG}\" = \"true\" ]; then
  echo \"husky:debug $HOOK_NAME hook started...\"
fi

if [ -f $SCRIPT_PATH ]; then
  $SCRIPT_PATH $HOOK_NAME \"$GIT_PARAMS\"
else
  echo \"Can't find Husky, skipping $HOOK_NAME hook\"
  echo \"You can reinstall husky or this hook\"
fi
"
  end



 end
