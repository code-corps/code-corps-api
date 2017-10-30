defmodule CodeCorps.Mixfile do
  @moduledoc false

  alias CodeCorps.{
    Analytics, GitHub, Policy, StripeService, StripeTesting
  }

  use Mix.Project

  def project do
    [app: :code_corps,
     version: "0.0.1",
     elixir: "~> 1.5.0",
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
      extra_applications: [:scout_apm, :timex, :tzdata]
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
      {:cloudex, "~> 0.2.2"},
      {:comeonin, "~> 3.1"},
      {:corsica, "~> 1.0"}, # CORS
      {:credo, "~> 0.8", only: [:dev, :test]}, # Code style suggestions
      {:earmark, "~> 1.2"}, # Markdown rendering
      {:ecto_ordered, "0.2.0-beta1"},
      {:ex_aws, "~> 1.0"}, # Amazon AWS
      {:excoveralls, "~> 0.7", only: :test}, # Test coverage
      {:ex_doc, "~> 0.17", only: [:dev, :test]},
      {:ex_machina, "~> 2.0", only: :test}, # test factories
      {:guardian, "~> 0.14.5"}, # Authentication (JWT)
      {:hackney, ">= 1.4.4"},
      {:httpoison, "~> 0.13"},
      {:inch_ex, "~> 0.5", only: [:dev, :test]}, # Inch CI
      {:inflex, "~> 1.8.1"},
      {:ja_serializer, "~> 0.12"}, # JSON API
      {:joken, "~> 1.5"}, # JWT encoding
      {:jsonapi, "~> 0.1.0"},
      {:money, "~> 1.2.1"},
      {:poison, "~> 3.0", override: true},
      {:scout_apm, "~> 0.0"},
      {:scrivener_ecto, "~> 1.2"}, # DB query pagination
      {:segment, "~> 0.1"}, # Segment analytics
      {:sentry, "~> 6.0"}, # Sentry error tracking
      {:stripity_stripe, git: "https://github.com/code-corps/stripity_stripe.git", branch: "2.0"}, # Stripe
      {:sweet_xml, "~> 0.5"},
      {:timber, "~> 2.0"}, # Logging
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"}
    ]
  end

  defp docs do
    [
      main: "README",
      source_url: "https://github.com/code-corps/code-corps-api",
      groups_for_modules: groups_for_modules(),
      extras: [
        "README.md": [title: "README"],
        "LICENSE.md": [title: "LICENSE"]
      ],
    ]
  end

  defp groups_for_modules do
    [
      "Models": [
        CodeCorps.Accounts,
        CodeCorps.Accounts.Changesets,
        CodeCorps.AuthToken,
        CodeCorps.Category,
        CodeCorps.Comment,
        CodeCorps.DonationGoal,
        CodeCorps.GithubAppInstallation,
        CodeCorps.GithubComment,
        CodeCorps.GithubEvent,
        CodeCorps.GithubIssue,
        CodeCorps.GithubPullRequest,
        CodeCorps.GithubRepo,
        CodeCorps.MapUtils,
        CodeCorps.Model,
        CodeCorps.Organization,
        CodeCorps.OrganizationGithubAppInstallation,
        CodeCorps.OrganizationInvite,
        CodeCorps.Preview,
        CodeCorps.Project,
        CodeCorps.Project.Query,
        CodeCorps.ProjectCategory,
        CodeCorps.ProjectGithubRepo,
        CodeCorps.ProjectSkill,
        CodeCorps.ProjectUser,
        CodeCorps.Repo,
        CodeCorps.Role,
        CodeCorps.RoleSkill,
        CodeCorps.Skill,
        CodeCorps.SluggedRoute,
        CodeCorps.StripeConnectAccount,
        CodeCorps.StripeConnectCard,
        CodeCorps.StripeConnectCharge,
        CodeCorps.StripeConnectCustomer,
        CodeCorps.StripeConnectPlan,
        CodeCorps.StripeConnectSubscription,
        CodeCorps.StripeEvent,
        CodeCorps.StripeExternalAccount,
        CodeCorps.StripeFileUpload,
        CodeCorps.StripeInvoice,
        CodeCorps.StripePlatformCard,
        CodeCorps.StripePlatformCustomer,
        CodeCorps.Task,
        CodeCorps.Task.Query,
        CodeCorps.TaskList,
        CodeCorps.TaskSkill,
        CodeCorps.Transition.UserState,
        CodeCorps.User,
        CodeCorps.UserCategory,
        CodeCorps.UserRole,
        CodeCorps.UserSkill,
        CodeCorps.UserTask,
        CodeCorps.Validators.SlugValidator,
        CodeCorps.Validators.TimeValidator
      ],

      "Services": [
        CodeCorps.Comment.Service,
        CodeCorps.Services.DonationGoalsService,
        CodeCorps.Services.ForgotPasswordService,
        CodeCorps.Services.MarkdownRendererService,
        CodeCorps.Services.ProjectService,
        CodeCorps.Services.UserService,
        CodeCorps.Task.Service
      ],

      "Policies": [
        Policy,
        Policy.Category,
        Policy.Comment,
        Policy.DonationGoal,
        Policy.GithubAppInstallation,
        Policy.Helpers,
        Policy.Organization,
        Policy.OrganizationGithubAppInstallation,
        Policy.OrganizationInvite,
        Policy.Preview,
        Policy.Project,
        Policy.ProjectCategory,
        Policy.ProjectGithubRepo,
        Policy.ProjectSkill,
        Policy.ProjectUser,
        Policy.Role,
        Policy.RoleSkill,
        Policy.Skill,
        Policy.StripeConnectAccount,
        Policy.StripeConnectPlan,
        Policy.StripeConnectSubscription,
        Policy.StripePlatformCard,
        Policy.StripePlatformCustomer,
        Policy.Task,
        Policy.TaskSkill,
        Policy.User,
        Policy.UserCategory,
        Policy.UserRole,
        Policy.UserSkill,
        Policy.UserTask
      ],

      "Helpers": [
        CodeCorps.Helpers.Query,
        CodeCorps.Helpers.RandomIconColor,
        CodeCorps.Helpers.Slug,
        CodeCorps.Helpers.String,
        CodeCorps.Helpers.URL,
        CodeCorps.RandomIconColor.Generator,
        CodeCorps.RandomIconColor.TestGenerator
      ],

      "Emails": [
        CodeCorps.Mailer,
        CodeCorps.Emails.BaseEmail,
        CodeCorps.Emails.ForgotPasswordEmail,
        CodeCorps.Emails.OrganizationInviteEmail,
        CodeCorps.Emails.ProjectUserAcceptanceEmail,
        CodeCorps.Emails.ReceiptEmail
      ],

      "Web": [
        CodeCorpsWeb,
        CodeCorpsWeb.Endpoint,
        CodeCorpsWeb.ErrorHelpers,
        CodeCorpsWeb.Gettext,
        CodeCorpsWeb.GuardianSerializer,
        CodeCorpsWeb.Router,
        CodeCorpsWeb.Router.Helpers,
        CodeCorpsWeb.UserSocket
      ],

      "Web – Plugs": [
        CodeCorpsWeb.Plug.AnalyticsIdentify,
        CodeCorpsWeb.Plug.CurrentUser,
        CodeCorpsWeb.Plug.DataToAttributes,
        CodeCorpsWeb.Plug.IdsToIntegers,
        CodeCorpsWeb.Plug.Segment,
        CodeCorpsWeb.Plug.SetSentryUserContext
      ],

      "Miscellaneous": [
        CodeCorps.Adapter.MapTransformer,
        CodeCorps.ConnUtils,
        CodeCorps.Presenters.ImagePresenter,
        CodeCorps.WebClient
      ],

      "GitHub – API": [
        GitHub,
        GitHub.HTTPClientError,
        GitHub.Utils.ResultAggregator,
        GitHub.API,
        GitHub.API.Comment,
        GitHub.API.Headers,
        GitHub.API.Installation,
        GitHub.API.Issue,
        GitHub.API.JWT,
        GitHub.API.PullRequest,
        GitHub.API.User,
        GitHub.APIError,
        GitHub.APIErrorObject
      ],

      "GitHub – Sync": [
        GitHub.Sync,
        GitHub.Sync.Comment,
        GitHub.Sync.Comment.Comment,
        GitHub.Sync.Comment.Comment.Changeset,
        GitHub.Sync.Comment.GithubComment,
        GitHub.Sync.Issue,
        GitHub.Sync.Issue.GithubIssue,
        GitHub.Sync.Issue.Task,
        GitHub.Sync.Issue.Task.Changeset,
        GitHub.Sync.PullRequest,
        GitHub.Sync.PullRequest.BodyParser,
        GitHub.Sync.PullRequest.GithubPullRequest,
        GitHub.Sync.User.RecordLinker,
        GitHub.Sync.Utils.RepoFinder
      ],

      "Github – Webhooks": [
        GitHub.Webhook.EventSupport,
        GitHub.Webhook.Handler,
        GitHub.Webhook.Processor,
        GitHub.Event,
        GitHub.Event.Handler,
        GitHub.Event.Installation,
        GitHub.Event.Installation.ChangesetBuilder,
        GitHub.Event.Installation.MatchedUser,
        GitHub.Event.Installation.Repos,
        GitHub.Event.Installation.UnmatchedUser,
        GitHub.Event.Installation.Validator,
        GitHub.Event.InstallationRepositories,
        GitHub.Event.InstallationRepositories.Validator,
        GitHub.Event.IssueComment,
        GitHub.Event.IssueComment.CommentDeleter,
        GitHub.Event.IssueComment.Validator,
        GitHub.Event.Issues,
        GitHub.Event.Issues.Validator,
        GitHub.Event.PullRequest,
        GitHub.Event.PullRequest.Validator
      ],

      "GitHub – Adapters": [
        GitHub.Adapters.AppInstallation,
        GitHub.Adapters.Comment,
        GitHub.Adapters.Issue,
        GitHub.Adapters.PullRequest,
        GitHub.Adapters.Repo,
        GitHub.Adapters.User,
        GitHub.Adapters.Utils.BodyDecorator
      ],

      "Stripe – Services": [
        StripeService.StripeConnectAccountService,
        StripeService.StripeConnectCardService,
        StripeService.StripeConnectChargeService,
        StripeService.StripeConnectCustomerService,
        StripeService.StripeConnectExternalAccountService,
        StripeService.StripeConnectPlanService,
        StripeService.StripeConnectSubscriptionService,
        StripeService.StripeInvoiceService,
        StripeService.StripePlatformCardService,
        StripeService.StripePlatformCustomerService
      ],

      "Stripe – Webhooks": [
        StripeService.WebhookProcessing.ConnectEventHandler,
        StripeService.WebhookProcessing.EnvironmentFilter,
        StripeService.WebhookProcessing.EventHandler,
        StripeService.WebhookProcessing.IgnoredEventHandler,
        StripeService.WebhookProcessing.PlatformEventHandler,
        StripeService.WebhookProcessing.WebhookProcessor,
        StripeService.Events.AccountUpdated,
        StripeService.Events.ConnectChargeSucceeded,
        StripeService.Events.ConnectExternalAccountCreated,
        StripeService.Events.CustomerSourceUpdated,
        StripeService.Events.CustomerSubscriptionDeleted,
        StripeService.Events.CustomerSubscriptionUpdated,
        StripeService.Events.CustomerUpdated,
        StripeService.Events.InvoicePaymentSucceeded
      ],

      "Stripe – Adapters": [
        StripeService.Adapters.StripeConnectAccountAdapter,
        StripeService.Adapters.StripeConnectCardAdapter,
        StripeService.Adapters.StripeConnectChargeAdapter,
        StripeService.Adapters.StripeConnectCustomerAdapter,
        StripeService.Adapters.StripeConnectPlanAdapter,
        StripeService.Adapters.StripeConnectSubscriptionAdapter,
        StripeService.Adapters.StripeEventAdapter,
        StripeService.Adapters.StripeExternalAccountAdapter,
        StripeService.Adapters.StripeFileUploadAdapter,
        StripeService.Adapters.StripeInvoiceAdapter,
        StripeService.Adapters.StripePlatformCardAdapter,
        StripeService.Adapters.StripePlatformCustomerAdapter,
      ],

      "Stripe – Validators": [
        StripeService.Validators.ProjectCanEnableDonations,
        StripeService.Validators.ProjectSubscribable,
        StripeService.Validators.UserCanSubscribe,
      ],

      "Stripe – Testing": [
        StripeTesting.Account,
        StripeTesting.Card,
        StripeTesting.Charge,
        StripeTesting.Customer,
        StripeTesting.Event,
        StripeTesting.ExternalAccount,
        StripeTesting.Helpers,
        StripeTesting.Invoice,
        StripeTesting.Plan,
        StripeTesting.Subscription,
        StripeTesting.Token
      ],

      "Analytics": [
        Analytics.InMemoryAPI,
        Analytics.SegmentAPI,
        Analytics.SegmentDataExtractor,
        Analytics.SegmentEventNameBuilder,
        Analytics.SegmentPlugTracker,
        Analytics.SegmentTracker,
        Analytics.SegmentTrackingSupport,
        Analytics.SegmentTraitsBuilder,
        Analytics.TestAPI
      ],

      "Cloudinary": [
        CodeCorps.Cloudex.CloudinaryUrl,
        CodeCorps.Cloudex.Uploader,
        CloudexTest,
        CloudexTest.Url
      ]
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
     "test": ["ecto.create --quiet", "ecto.migrate", "test"],
     "test.acceptance": ["ecto.create --quiet", "ecto.migrate", "test --include acceptance:true"]]
  end
end
