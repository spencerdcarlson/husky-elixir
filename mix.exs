defmodule Husky.MixProject do
  use Mix.Project

  def project do
    [
      app: :husky,
      version: "0.1.0",
      description:
        "Git hooks made easy. Husky can prevent bad git commit, git push and more 🐶 ❤️ woof! - Elixir equivalent of the husky npm package",
      package: package(),
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      source_url: "",
      homepage_url: ""
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com",
        "Original NPM package" => "https://github.com/typicode/husky"
      }
    ]
  end

  #  # Run "mix help compile.app" to learn about applications.
  #  def application do
  #    [
  #      extra_applications: [:logger]
  #    ]
  #  end

  defp escript do
    [
      main_module: Husky
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
