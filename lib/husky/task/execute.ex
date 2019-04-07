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
      |> parse_args()
      |> fetch_command()

    case command do
      {:error, :no_cmd} ->
        System.halt()

      {:ok, {hook, cmd}} ->
        running_message()

        cmd
        |> execute_cmd()
        |> handle_result(%{hook: hook, cmd: cmd})
    end
  end

  defp handle_result({0, out}, %{hook: hook, cmd: cmd}) do
    """
    #{out}
    #{green()}
    husky > #{hook} ('#{cmd}')
    #{reset()}
    """
    |> IO.puts()

    System.halt()
  end

  defp handle_result({code, out}, %{hook: hook, cmd: cmd}) do
    """
    #{out}
    #{red()}
    husky > #{hook} ('#{cmd}') failed #{no_verify_message(hook)}
    #{reset()}
    """
    |> IO.puts()

    System.halt(code)
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
    command =
      word
      |> normalize()
      |> config()

    case command do
      {:ok, cmd} -> {:ok, {word, cmd}}
      {:error, :config} -> {:error, :no_cmd}
    end
  end

  defp execute_cmd(cmd) do
    result =
      "#{cmd}; echo $?"
      |> to_charlist()
      |> :os.cmd()
      |> to_string()

    {code, out} =
      result
      |> String.split("\n")
      |> List.pop_at(-2)

    {String.to_integer(code), Enum.join(out, "\n")}
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
    with {:module, parser} <-
           Code.ensure_loaded(Application.get_env(:husky, :json_codec, Poison)),
         {:ok, body} <- File.read(file),
         {:ok, json} <- parser.decode(body) do
      normalize(json["husky"]["hooks"])
    else
      {:error, reason} ->
        """
        #{yellow()}
        husky > JSON parsing failed
          Ensure that either Poison is available or that :json_codec is set and is available
          Error: #{inspect(reason)}
        #{reset()}
        """
        |> IO.puts()

        %{}
    end
  end

  defp normalize(map) when is_map(map) do
    for {key, value} <- map, into: %{} do
      if is_map(value), do: {normalize(key), normalize(value)}, else: {normalize(key), value}
    end
  end

  defp normalize(key) when is_binary(key) do
    key
    |> String.replace("-", "_")
    |> String.to_atom()
  end
end
