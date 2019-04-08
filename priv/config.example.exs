use Mix.Config

config :husky,
       pre_commit: "mix format --check-formatted && mix credo",
       pre_push: "mix test"

