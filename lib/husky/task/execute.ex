defmodule Mix.Tasks.Husky.Execute do
  import IO.ANSI

  @moduledoc """
  Mix task to invoke a system command set by a husky config file

  ## Examples
  With the given config file:
  ```elixir
  config :husky, pre_commit: "mix format"
  ```

  ```bash
  mix husky.execute pre-commit
  ```
  Would execute `mix format`
  """

  use Mix.Task

  @doc """
  mix task to execute husky config commands.

  ## Examples
  `mix husky.execute pre-commit`
  """
  def run(argv) do
    command =
      argv
      |> parse_args
      |> fetch_command

    case command do
      {:error, :no_cmd} ->
        System.halt()

      {:ok, {hook, cmd}} ->
        running_message()

        case execute_cmd(cmd) do
          {0, out} ->
            """
            #{out}
            #{green()}
            husky > #{hook} ('#{cmd}')
            #{reset()}
            """
            |> IO.puts()

            System.halt()

          {code, out} ->
               """
               #{out}
               #{red()}
               husky > #{hook} ('#{cmd}') failed #{no_verify_message(hook)}
               #{reset()}
               """
            |> IO.puts()

            System.halt(code)
        end
    end
  end

  defp no_verify_message(hook) do
    if hook in [
         "commit-msg",
         "pre-commit",
         "pre-rebase",
         "pre-push"
       ] do
      "(add --no-verify to bypass)"
    else
      "(cannot be bypassed with --no-verify due to Git specs)"
    end
  end

  defp running_message do
    """
    🐶
    .... running husky hook
    """
    |> IO.puts()
  end

  defp parse_args(argv) do
    # { keyword list of parsed switches, list of the remaining arguments in argv, a list of invalid options}
    {parsed, args, _} =
      argv
      |> OptionParser.parse(
        switches: [upcase: :boolean],
        aliases: [u: :upcase]
      )

    {parsed, List.to_string(args)}
  end

  defp fetch_command({_, word}) do
    # {[], "pre-commit"} # example args
    IO.inspect(word, label: "parsed options (word)")

    command =
      word
      |> String.replace("-", "_")
      |> String.to_atom()
      |> config

    case command do
      {:ok, cmd} -> {:ok, {word, cmd}}
      {:error, :config} -> {:ok, :no_cmd}
    end
  end

  defp execute_cmd(cmd) do
    result =
    "#{cmd}; echo $?"
    |> to_char_list()
    |> :os.cmd()
    |> to_string()

    {code, out} = result |> String.split("\n") |> List.pop_at(-2)
    {String.to_integer(code), Enum.join(out, "\n")}

#    {cmd, args} =
#      String.split(cmd, " ")
#      |> List.pop_at(0)
#
#    # if cmd is "mix test --trace" => { mix, ["test", "--trace"] }
#
#    {:ok, cmd, System.cmd(cmd, args, stderr_to_stdout: true)}
  end

  defp config(key) do
    # source list order determines value precedence. - See Map.merge/2
    # If there are conflicting keys in multiple configuration files last item in the source list will take precedence.
    # if config :husky, pre_commit: "mix format" exists in config/config.exs and
    # { "husky": { "hooks": { "pre_commit": "npm test" } } }
    # is in .husky.json, then which ever file is last in the sources list will determine the value for pre_commit

    # get all config files
    # list of tuples { config_exists?, %{configs} }
    config_map =
      [
        {File.exists?(".husky.json"), parse_json(".husky.json")},
        {not Enum.empty?(Application.get_all_env(:husky)),
         Map.new(Application.get_all_env(:husky))}
      ]
      |> Stream.filter(&elem(&1, 0))
      |> Stream.map(&elem(&1, 1))
      |> Enum.reduce(%{}, &Map.merge(&2, &1))

    if Map.has_key?(config_map, key), do: {:ok, config_map[key]}, else: {:error, :config}
  end

  defp parse_json(file) do
    with {:ok, body} <- File.read(file),
         {:ok, json} <- Poison.decode(body) do
      # maybe add error handling for badly formatted JSON
      # nil will throw a Protocol.UndefinedError
      json["husky"]["hooks"]
      |> Map.new(&{String.to_atom(&1), &2})
    end
  end
end
