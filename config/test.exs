use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

config :husky,
  git_root_location: "dev/sandbox/git",
  git_hooks_location: "dev/sandbox/git/hooks",
  script_path: "../../../../priv/husky"
