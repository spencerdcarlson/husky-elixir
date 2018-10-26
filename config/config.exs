use Mix.Config

config :husky,
  git_root_location: ".git",
  git_hooks_location: ".git/hooks",
  hook_list: [
    "applypatch-msg",
    "pre-applypatch",
    "post-applypatch",
    "pre-commit",
    "prepare-commit-msg",
    "commit-msg",
    "post-commit",
    "pre-rebase",
    "post-checkout",
    "post-merge",
    "pre-push",
    "pre-receive",
    "update",
    "post-receive",
    "post-update",
    "push-to-checkout",
    "pre-auto-gc",
    "post-rewrite",
    "sendemail-validate"
  ],
  husky_config_location: "./deps/husky/config/config.exs"

import_config "#{Mix.env()}.exs"
