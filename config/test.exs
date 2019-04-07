use Mix.Config

config :husky,
  host_path: "./dev/sandbox",
  escript_path: "./priv/husky",
  pre_commit: "mix test",
  pre_push: "mix test"
