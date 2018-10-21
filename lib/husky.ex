defmodule Husky do
  #  use Mix.Task
  #
  #  def run(args) do
  #    IO.puts("install hook")
  #    Mix.shell.info Enum.join(args, " ")
  #  end

  @moduledoc """
  Documentation for Husky.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Husky.hello()
      :world

  """

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

  @app Mix.Project.config()[:app]
  @version Mix.Project.config()[:version]
  @script_path "./husky"

  def main(argv \\ []) do
    argv
    |> IO.inspect()
    |> parse_args
    |> process_options()
    |> IO.inspect()
  end

  defp parse_args(argv) do
    # { keyword list of parsed switches, list of the remaining arguments in argv, a list of invalid options}
    {parsed, args, _} =
      argv
      |> OptionParser.parse(
        switches: [upcase: :boolean, install: :boolean],
        aliases: [u: :upcase, i: :install]
      )

    {parsed, List.to_string(args)}
  end

  defp process_options({opts, word}) do
    IO.inspect({opts, word})

    case {opts, word} do
      {[], ""} ->
        IO.puts("no command line arguments")

      _ ->
        if opts[:install] do
          @hook_list
          |> install_hook_scripts("debug/")

          config?()
          |> IO.inspect()
        end

        if opts[:upcase], do: String.upcase(word), else: word
    end
  end

  def hello do
    :world
  end

  def double_sum(x, y) do
    x = 2 * x
    y = 2 * y
    x + y
  end

  def config? do
    # source list order determines value precedence.
    # If there are conflicting keys in multiple configuration files last item in the source list will take precedence.
    # if config :husky, pre_commit: "mix format" exists in config/config.exs and
    # { "husky": { "hooks": { "pre_commit": "npm test" } } }
    # is in .husky.json, then which ever file is last in the sources list will determine the value for pre_commit
    sources = [
      {File.exists?(".husky.json"), parse_json(".husky.json")},
      {List.first(Application.get_all_env(:husky)) != nil,
       Application.get_all_env(:husky) |> Map.new()}
    ]

    list =
      Enum.reduce(sources, [], fn
        {true, item}, list -> [item | list]
        _, list -> list
      end)

    list
    |> Enum.reduce(fn x, acc -> Map.merge(x, acc) end)
  end

  def parse_json(file) do
    with {:ok, body} <- File.read(file),
         {:ok, json} <- Poison.decode(body) do
      # maybe add error handling for badly formatted JSON
      json["husky"]["hooks"]
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    end
  end

  def hooks do
  end

  def run(script_path, hook, git_params) do
  end

  def install_hook_scripts(hook_list, install_directory) do
    if not File.dir?(".git") do
      raise RuntimeError,
        message: ".git or .git/hooks directory does not exist. HINT: run $ git init"
    end

    if not File.dir?(".git/hooks") do
      File.mkdir!(".git/hooks")
    end

    hook_list
    |> Enum.map(fn x ->
      with {:ok, file} <- File.open(install_directory <> x, [:write]) do
        IO.binwrite(file, hook_script_content())
      end
    end)
  end

  def hook_script_content() do
    "#!/bin/env sh
# #{@app}
# #{@version} #{
      :os.type()
      |> Tuple.to_list()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(fn x -> x <> " " end)
    }
SCRIPT_PATH=#{@script_path}
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
