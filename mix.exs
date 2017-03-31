defmodule CodeCorps.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [app: :code_corps,
     version: "0.0.1",
     elixir: "1.4.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     dialyzer: [plt_add_deps: :transitive],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     docs: docs(),
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CodeCorps, []},
      applications: [
        :bamboo,
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :cloudex,
        :comeonin,
        :corsica,
        :earmark,
        :ex_aws,
        :httpoison,
        :ja_resource,
        :scrivener_ecto,
        :segment,
        :sentry,
        :stripity_stripe,
        :timber,
        :timex_ecto
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 0.7"}, # emails
      {:bamboo_postmark, "~> 0.2.0"}, # postmark adapter for emails
      {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.3.0-rc", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.8"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.12"},
      {:cowboy, "~> 1.0"},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:canary, "~> 1.1"}, # Authorization
      {:cloudex, "~> 0.1.10"},
      {:comeonin, "~> 2.0"},
      {:corsica, "~> 0.4"}, # CORS
      {:credo, "~> 0.5", only: [:dev, :test]}, # Code style suggestions
      {:earmark, "~> 1.1"}, # Markdown rendering
      {:ex_aws, "~> 1.0"}, # Amazon AWS
      {:excoveralls, "~> 0.5", only: :test}, # Test coverage
      {:ex_doc, "~> 0.14", only: [:dev, :test]},
      {:ex_machina, "~> 1.0", only: :test}, # test factories
      {:guardian, "~> 0.13"}, # Authentication (JWT)
      {:hackney, ">= 1.4.4"},
      {:inch_ex, "~> 0.5", only: [:dev, :test]}, # Inch CI
      {:inflex, "~> 1.8"},
      {:ja_resource, "~> 0.2"},
      {:ja_serializer, "~> 0.11.0"}, # JSON API
      {:mix_test_watch, "~> 0.2", only: :dev}, # Test watcher
      {:money, "~> 1.2.1"},
      {:poison, "~> 2.0"},
      {:scrivener_ecto, "~> 1.0"}, # DB query pagination
      {:segment, "~> 0.1"}, # Segment analytics
      {:sentry, "~> 2.0"}, # Sentry error tracking
      {:stripity_stripe, git: "https://github.com/code-corps/stripity_stripe.git", branch: "2.0"}, # Stripe
      {:sweet_xml, "~> 0.5"},
      {:timber, "~> 0.4"}, # Logging
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
      {:ecto_ordered, "0.2.0-beta1"}
    ]
  end

  defp docs do
    [
      extras: [
        "README.md": [title: "README"],
        "LICENSE.md": [title: "LICENSE"]
      ],
      main: "README",
      source_url: "https://github.com/code-corps/code-corps-api/doc"
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
     "ecto.migrate": ["ecto.migrate", "ecto.dump"],
     "ecto.rollback": ["ecto.rollback", "ecto.dump"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
