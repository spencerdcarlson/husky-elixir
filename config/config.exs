use Mix.Config

config :logger, backends: [{LoggerFileBackend, :info}]

config :logger, :info,
  path: "info.log",
  level: :info

config :husky,
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
  pre_commit: "mix format",
  pre_push: "mix test"
