defmodule Server.Mixfile do
  use Mix.Project

  def project do
    [
      app: :server,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Server.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:ecto_enum, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:httpoison, "1.2.0", override: true},
      {:jason, ">= 1.0.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.3.3"},
      {:postgrex, ">= 0.0.0"},
      {:secure_random, "~> 0.5"},
      {:tentacat, "~> 1.0"},
      {:tesla, "~> 1.0.0"},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth, "~> 0.4"},
      {:ex_machina, "~> 2.2"},
      {:timex, "~> 3.1"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
