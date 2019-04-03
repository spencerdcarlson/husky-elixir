use Mix.Config

config :husky,
       path_to_consumer: "../jq"

config :husky, pre_commit: "mix test"

import_config "#{Mix.env()}.exs"
