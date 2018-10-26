# Husky
> Git hooks made easy

## Description
Husky is an exlir version of the [husky](https://www.npmjs.com/package/husky) npm module.

Husky can prevent bad `git commit`, `git push` and more 🐶 ❤️ _woof!_



## Installation
The [Husky](https://hex.pm/packages/husky) Hex package can be installed 
by adding `husky` to your list of dependencies in `mix.exs`: 
```elixir
defp deps do
  [
    {:husky, "~> 0.1.5"}
  ]
end
```

## Usage
* Run `mix husky.install` to install husky git hook scripts
* Configure git hook commands in either your `config/config.exs` or a `.husky.json` file
    * *Note: `config/config.exs` will take precedence over `.husky.json` if there are key conflicts*


##### Configure Git Hooks Using `config/config.exs`:
```elixir
use Mix.Config
config :husky,
    pre_commit: "mix format",
    pre_push: "mix test"
```
View example file [config.example.exs](./priv/config.example.exs) 

##### Configure Git Hooks Using `.husky.json`:
```JSON
{
  "husky": {
    "hooks": {
      "pre_commit": "mix format",
      "pre_push": "mix test"
    }
  }
}
```
View example file [.husky.example.json](./priv/config.example.exs) 

Documentation can found at [https://hexdocs.pm/husky](https://hexdocs.pm/husky).

