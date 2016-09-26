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
     deps: deps(),
     test_coverage: [tool: ExCoveralls]]
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
        :arc_ecto,
        :comeonin,
        :corsica,
        :earmark,
        :ex_aws,
        :httpoison,
        :scrivener_ecto,
        :segment,
        :stripity_stripe
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
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:arc, git: "https://github.com/stavro/arc.git", ref: "354d4d2e1b86bcd6285db3528118fe3f5db36cf5", override: true}, # Photo uploads
      {:arc_ecto, "~> 0.4.4"},
      {:canary, "~> 1.0"}, # Authorization
      {:comeonin, "~> 2.0"},
      {:corsica, "~> 0.4"}, # CORS
      {:credo, "~> 0.4", only: [:dev, :test]}, # Code style suggestions
      {:earmark, "~> 1.0"}, # Markdown rendering
      {:ex_aws, "~> 0.4"}, # Amazon AWS
      {:excoveralls, "~> 0.5", only: :test}, # Test coverage
      {:ex_machina, "~> 1.0", only: :test}, # test factories
      {:guardian, "~> 0.13"}, # Authentication (JWT)
      {:inch_ex, "~> 0.5", only: [:dev, :test]}, # Inch CI
      {:inflex, "~> 1.7.0"},
      {:ja_serializer, "~> 0.10.1"}, # JSON API
      {:mix_test_watch, "~> 0.2", only: :dev}, # Test watcher
      {:poison, "~> 1.2 or ~> 2.0"},
      {:scrivener_ecto, "~> 1.0"}, # DB query pagination
      {:segment, github: "stueccles/analytics-elixir"}, # Segment analytics
      {:stripity_stripe, "~> 1.4.0"} # Stripe
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
