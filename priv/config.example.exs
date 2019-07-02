use Mix.Config

config :husky,
      pre_commit: "mix format && mix credo --strict",
      pre_push: "mix format --check-formatted && mix credo --strict && mix test"
