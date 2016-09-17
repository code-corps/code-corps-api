defmodule CodeCorps.Mixfile do
  use Mix.Project

  def project do
    [app: :code_corps,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CodeCorps, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :comeonin,
        :corsica,
        :earmark,
        :ex_aws,
        :httpoison,
        :arc_ecto,
        :scrivener_ecto,
        :segment
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ja_serializer, "~> 0.10"}, # JSON API
      {:guardian, "~> 0.12.0"}, # Authentication (JWT)
      {:comeonin, "~> 2.0"},
      {:mix_test_watch, "~> 0.2", only: :dev}, # Test watcher
      {:credo, "~> 0.4", only: [:dev, :test]}, # Code style suggestions
      {:inflex, "~> 1.7.0"},
      {:corsica, "~> 0.4"}, # CORS
      {:earmark, "~> 1.0"}, # Markdown rendering
      {:ex_machina, "~> 1.0", only: :test}, # test factories
      {:arc, git: "https://github.com/stavro/arc.git", ref: "354d4d2e1b86bcd6285db3528118fe3f5db36cf5", override: true}, # Photo uploads
      {:arc_ecto, "~> 0.4.3"},
      {:ex_aws, "~> 0.4.10"}, # Amazon AWS
      {:httpoison, "~> 0.7"},
      {:poison, "~> 1.2"},
      {:canary, "~> 0.14.2"}, # Authorization
      {:scrivener_ecto, "~> 1.0"}, # DB query pagination
      {:segment, github: "stueccles/analytics-elixir"} # Segment analytics
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
