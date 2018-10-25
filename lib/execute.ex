defmodule Mix.Tasks.Husky.Execute do
  use Mix.Task
  require Logger

  def run(argv) do
    Logger.info("...running husky execute task")

    {result, out, code} =
      argv
      |> parse_args
      |> process_options()

    Logger.debug("stderr and stdout: #{inspect(out)}")
    Logger.debug("exit code: #{inspect(code)}")
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

  defp process_options({_, word}) do
    key =
      word
      |> String.replace("-", "_")
      |> String.to_atom()

    Logger.debug("key: #{inspect(key)}")
    with {:ok, value} <- config(key),
          list <- String.split(value, " "),
         {cmd, args} <- List.pop_at(list, 0) do
      Logger.debug("execute '#{inspect(cmd)}' with args '#{inspect(args)}'")
      {:ok, System.cmd(cmd, args, stderr_to_stdout: true)}
    else
      {:error, map} ->
      Logger.debug("error looking up '#{key}' in configs: #{inspect(map)}")
      {:error, "", ""}

    end


  end

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
    map

    if Map.has_key?(map, key) do
      {:ok, map[key]}
    else
      {:error, map}
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
