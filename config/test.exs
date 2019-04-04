use Mix.Config

config :logger, :console,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

config :husky,
  path_to_consumer: "./dev/sandbox",
  escript_path: "./priv/husky",
  pre_commit: "mix format",
  pre_push: "mix test"
