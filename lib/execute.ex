defmodule Mix.Tasks.Husky.Execute do
  use Mix.Task
  require Logger

  @app Mix.Project.config()[:app]

  def run(argv) do
    Logger.debug("...running 'husky.execute' task")
    Mix.shell().info("...running 'husky.execute' task")

    result =
      argv
      |> parse_args
      |> process_options()

    case result do
      {:ok, cmd, {out, code}} ->
        Logger.debug(
          "System.cmd executed. cmd='#{cmd}' return_code=#{inspect(code)} stdout_stderr=#{
            inspect(out)
          }"
        )

        if code == 0 do
          Logger.debug("'$ #{cmd}' was executed successfully:")
          Mix.shell().info("'$ #{cmd}' was executed successfully:")
          Mix.shell().info(out)
        else
          Logger.debug("$ '#{cmd}' was executed, but failed:")
          Mix.shell().info("'$ #{cmd}' was executed, but failed:")
          Mix.shell().error(out)
        end

        System.halt(code)

      {:error, :key_not_found, key, map} ->
        Mix.shell().info(
          "A git hook command for '#{key}' was not found in any config file. If you want to configure a git hook, add:\n\tconfig #{
            inspect(@app)
          }, #{inspect(key)} \"mix test\"\nto your config/config.exs file"
        )

        Logger.debug("'#{key}' was not found in configs. No System.cmd was executed")
        Logger.debug("config map=#{inspect(map)}")
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
    key =
      word
      |> String.replace("-", "_")
      |> String.to_atom()

    Logger.debug("git hook key converted to an atom: #{inspect(key)}")
    execute_cmd(config(key))
  end

  defp execute_cmd({:ok, value}) do
    {cmd, args} =
      String.split(value, " ")
      |> List.pop_at(0)

    # if value is "mix test --trace" => { mix, ["test", "--trace"] }

    {:ok, value, System.cmd(cmd, args, stderr_to_stdout: true)}
  end

  defp execute_cmd({:error, details, key, map}), do: {:error, details, key, map}

  def config(key) do
    # source list order determines value precedence.
    # If there are conflicting keys in multiple configuration files last item in the source list will take precedence.
    # if config :husky, pre_commit: "mix format" exists in config/config.exs and
    # { "husky": { "hooks": { "pre_commit": "npm test" } } }
    # is in .husky.json, then which ever file is last in the sources list will determine the value for pre_commit

    # get all config files
    # list of tuples { config_exists?, %{configs} }
    sources = [
      {File.exists?(".husky.json"), parse_json(".husky.json")},
      {not Enum.empty?(Application.get_all_env(:husky)),
       Application.get_all_env(:husky) |> Map.new()}
    ]

    Logger.debug("sources: #{inspect(sources)}")

    # filter out only configs that exist
    configs =
      Enum.reduce(sources, [], fn
        {true, config_hash}, acc -> [config_hash | acc]
        _, acc -> acc
      end)

    Logger.debug("existing config maps:  #{inspect(configs)}")

    # convert list of maps into one map
    map =
      Enum.reduce(configs, %{}, fn
        map, acc -> Map.merge(acc, map)
      end)

    Logger.debug("final flattened map: #{inspect(map)}")

    if Map.has_key?(map, key) do
      {:ok, map[key]}
    else
      {:error, :key_not_found, key, map}
    end
  end

  def parse_json(file) do
    with {:ok, body} <- File.read(file),
         {:ok, json} <- Poison.decode(body) do
      # maybe add error handling for badly formatted JSON
      json["husky"]["hooks"]
      |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    end
  end
end
