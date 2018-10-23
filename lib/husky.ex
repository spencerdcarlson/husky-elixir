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
    case {opts, word} do
      {[], ""} ->
        IO.puts("no command line arguments")

      _ ->
        IO.puts("args are not null")
        IO.inspect({opts, word})

        config

    end
  end

  def config do
    # source list order determines value precedence.
    # If there are conflicting keys in multiple configuration files last item in the source list will take precedence.
    # if config :husky, pre_commit: "mix format" exists in config/config.exs and
    # { "husky": { "hooks": { "pre_commit": "npm test" } } }
    # is in .husky.json, then which ever file is last in the sources list will determine the value for pre_commit

    # get all config files
    sources = [
      {File.exists?(".husky.json"), parse_json(".husky.json")},
      {List.first(Application.get_all_env(:husky)) != nil,
       Application.get_all_env(:husky) |> Map.new()}
    ]

    IO.puts("DEBUG: [{ exist?, %{configs} }]")
    IO.inspect(sources)

    # filter out only configs that exist
    list =
      Enum.reduce(sources, [], fn
        { true, config_hash }, acc -> [ config_hash | acc ]
        _, acc -> acc
      end)

    IO.puts("filter only configs that exist [%{configs}]")
    IO.inspect(list)

    # convert list of maps into one map
    result =
      Enum.reduce(list, %{}, fn
        map, acc -> Map.merge(acc, map)
    end)

    IO.puts("merge list of config maps into one config map")
    IO.inspect(result)

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
