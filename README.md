# Husky
=========
[![Build Status](https://travis-ci.org/spencerdcarlson/husky-elixir.svg?branch=master)](https://travis-ci.org/spencerdcarlson/husky-elixir)
> Git hooks made easy

## Description
Husky is an elixir version of the [husky](https://www.npmjs.com/package/husky) npm module.

Husky can prevent bad `git commit`, `git push` and more 🐶 ❤️ _woof!_



## Installation
The [Husky](https://hex.pm/packages/husky) Hex package can be installed 
by adding `husky` to your list of dependencies in `mix.exs`: 
```elixir
defp deps do
  [
    {:husky, "~> 1.0", only: :dev, runtime: false}
  ]
end
```

## Usage
* On compile, husky will install git hook scripts (`mix husky.install` to install manually)
* Configure git hook commands in either your `config/dev.exs` or a `.husky.json` file
    * *Note: `config/dev.exs` will take precedence over `.husky.json` if there are key conflicts*

##### Configure Git Hooks Using `config/config.exs`:
```elixir
use Mix.Config
config :husky,
    pre_commit: "mix format && mix credo --strict",
    pre_push: "mix format --check-formatted && mix credo --strict && mix test"
```
View example file [config.example.exs](./priv/config.example.exs) 

<details><summary>.husky.json</summary>
<p>

##### Configure Git Hooks Using `.husky.json`:
```JSON
{
  "husky": {
    "hooks": {
      "pre_commit": "mix format && mix credo --strict",
      "pre_push": "mix format --check-formatted && mix credo --strict && mix test"
    }
  }
}
```
View example file [.husky.example.json](./priv/.husky.example.json)
</p>
</details>

With the above setup:
* `git commit` will execute `mix format` and `mix credo --strict` and only commit if credo succeeds.
* `git push will execute `mix format`, `mix credo`, and `mix test`, and only push if all three commands succeed.
* `git commit --no-verify` still commit even if `mix credo --strict` fails

##### Skip script install
```bash
export HUSKY_SKIP_INSTALL=true
```

##### Delete 
* Remove git hook scripts `mix husky.delete`



Documentation can found at [https://hexdocs.pm/husky](https://hexdocs.pm/husky).

## Contributing
See the development [README.md](./dev/README.md)


