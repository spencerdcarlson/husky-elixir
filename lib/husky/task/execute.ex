defmodule Mix.Tasks.Husky.Execute do
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
    result =
      argv
      |> parse_args
      |> process_options()

    case result do
      {:ok, cmd, {out, 0}} ->
        """
        '$ #{cmd}' was executed successfully:
        #{out}
        """
        |> IO.puts()

        System.halt()

      {:ok, cmd, {out, code}} ->
        """
        '$ #{cmd}' was executed, but failed:
        #{out}
        """
        |> IO.puts()

        System.halt(code)

      {:error, :key_not_found, _key, _} ->
        System.halt()
        #        IO.puts(
        #          "A git hook command for '#{key}' was not found in any config file. If you want to configure a git hook, add:\n\tconfig #{
        #            inspect(Util.app())
        #          }, #{inspect(Atom.to_string(key) <> ":")} \"mix format\"\nto your config/config.exs file"
        #        )
    end
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

  defp process_options({_, word}) do
    # {[], "pre-commit"} # example args
    word
    |> String.replace("-", "_")
    |> String.to_atom()
    |> config()
    |> execute_cmd()
  end

  defp execute_cmd({:ok, value}) do
    {cmd, args} =
      String.split(value, " ")
      |> List.pop_at(0)

    # if value is "mix test --trace" => { mix, ["test", "--trace"] }

    {:ok, value, System.cmd(cmd, args, stderr_to_stdout: true)}
  end

  defp execute_cmd({:error, details, key, map}), do: {:error, details, key, map}

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

    if Map.has_key?(config_map, key) do
      {:ok, config_map[key]}
    else
      {:error, :key_not_found, key, config_map}
    end
  end

  defp parse_json(file) do
    with {:ok, body} <- File.read(file),
         {:ok, json} <- Poison.decode(body) do
      # maybe add error handling for badly formatted JSON
      # nil will throw a Protocol.UndefinedError
      json["husky"]["hooks"]
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    end
  end
end
