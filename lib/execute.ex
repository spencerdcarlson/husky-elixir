defmodule Mix.Tasks.Husky.Execute do
  use Mix.Task
  require Logger

  def run(argv) do
#    Logger.info("...running husky execute task")

    argv
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

  defp process_options({_, word}) do
    key =
      word
      |> String.replace("-", "_")
      |> String.to_atom()

    {cmd, args} =
      config()[key]
      |> String.split(" ")
      |> List.pop_at(0)

    {_, code} = System.cmd(cmd, args, stderr_to_stdout: true)
    code
  end

  def config do
    # source list order determines value precedence.
    # If there are conflicting keys in multiple configuration files last item in the source list will take precedence.
    # if config :husky, pre_commit: "mix format" exists in config/config.exs and
    # { "husky": { "hooks": { "pre_commit": "npm test" } } }
    # is in .husky.json, then which ever file is last in the sources list will determine the value for pre_commit

    # get all config files
    # list of tuples { config_exists?, %{configs} }
    [
      {File.exists?(".husky.json"), parse_json(".husky.json")},
      {not Enum.empty?(Application.get_all_env(:husky)),
       Application.get_all_env(:husky) |> Map.new()}
    ]
    # filter out only configs that exist
    |> Enum.reduce([], fn
      {true, config_hash}, acc -> [config_hash | acc]
      _, acc -> acc
    end)
    # convert list of maps into one map
    |> Enum.reduce(%{}, fn
      map, acc -> Map.merge(acc, map)
    end)
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
