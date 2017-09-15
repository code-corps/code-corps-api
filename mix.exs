defmodule CodeCorps.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [app: :code_corps,
     version: "0.0.1",
     elixir: "~> 1.5.1",
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
      extra_applications: [:timber, :timex, :tzdata]
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
      {:bamboo_postmark, "~> 0.4.1"}, # postmark adapter for emails
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.3"},
      {:phoenix_pubsub, "~> 1.0.2"},
      {:phoenix_ecto, "~> 3.2.3"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10.3"},
      {:phoenix_live_reload, "~> 1.0.8", only: :dev},
      {:gettext, "~> 0.12"},
      {:cowboy, "~> 1.0"},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:bypass, "~> 0.8.1", only: :test},
      {:canary, "~> 1.1.1"}, # Authorization
      {:cloudex, "~> 0.1.17"},
      {:comeonin, "~> 3.1"},
      {:corsica, "~> 1.0"}, # CORS
      {:credo, "~> 0.8", only: [:dev, :test]}, # Code style suggestions
      {:earmark, "~> 1.2"}, # Markdown rendering
      {:ecto_ordered, "0.2.0-beta1"},
      {:ex_aws, "~> 1.0"}, # Amazon AWS
      {:excoveralls, "~> 0.7", only: :test}, # Test coverage
      {:ex_doc, "~> 0.16", only: [:dev, :test]},
      {:ex_machina, "~> 2.0", only: :test}, # test factories
      {:guardian, "~> 0.14.5"}, # Authentication (JWT)
      {:hackney, ">= 1.4.4"},
      {:inch_ex, "~> 0.5", only: [:dev, :test]}, # Inch CI
      {:inflex, "~> 1.8.1"},
      {:ja_resource, "~> 0.2"},
      {:ja_serializer, "~> 0.12"}, # JSON API
      {:joken, "~> 1.5"}, # JWT encoding
      {:mix_test_watch, "~> 0.4", only: :dev}, # Test watcher
      {:money, "~> 1.2.1"},
      {:poison, "~> 3.0", override: true},
      {:scrivener_ecto, "~> 1.2"}, # DB query pagination
      {:segment, "~> 0.1"}, # Segment analytics
      {:sentry, "~> 6.0"}, # Sentry error tracking
      {:stripity_stripe, git: "https://github.com/code-corps/stripity_stripe.git", branch: "2.0"}, # Stripe
      {:sweet_xml, "~> 0.5"},
      {:tentacat, "~> 0.5"},
      {:timber, "~> 2.0"}, # Logging
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"}
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
