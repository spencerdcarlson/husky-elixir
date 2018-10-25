use Mix.Config

config :husky,
       pre_commit: "mix format",
       pre_push: "mix test"

