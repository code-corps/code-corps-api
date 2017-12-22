defmodule CodeCorpsWeb.Router do
  use CodeCorpsWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api", "json"]
    plug JaSerializer.Deserializer
  end

  pipeline :bearer_auth do
    plug CodeCorps.Auth.BearerAuthPipeline
  end

  pipeline :ensure_auth do
    plug CodeCorps.Auth.EnsureAuthPipeline
  end

  pipeline :current_user do
    plug CodeCorpsWeb.Plug.CurrentUser
    plug CodeCorpsWeb.Plug.SetTimberUserContext
    plug CodeCorpsWeb.Plug.SetSentryUserContext
    plug CodeCorpsWeb.Plug.AnalyticsIdentify
  end

  pipeline :stripe_webhooks do
    plug :accepts, ["json"]
  end

  pipeline :github_webhooks do
    plug :accepts, ["json"]
  end

  pipeline :tracking do
    plug CodeCorpsWeb.Plug.Segment
  end

  scope "/", CodeCorpsWeb do
    pipe_through [:browser] # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorpsWeb, host: "api." do
    pipe_through [:stripe_webhooks]

    post "/webhooks/stripe/connect", StripeConnectEventsController, :create
    post "/webhooks/stripe/platform", StripePlatformEventsController, :create
  end

  scope "/", CodeCorpsWeb, host: "api." do
    pipe_through [:github_webhooks]

    post "/webhooks/github", GithubEventController, :create, as: :github_events
  end

  scope "/", CodeCorpsWeb, host: "api." do
    pipe_through [:api, :bearer_auth, :ensure_auth, :current_user, :tracking]

    resources "/categories", CategoryController, only: [:create, :update]
    resources "/comments", CommentController, only: [:create, :update]
    resources "/conversations", ConversationController, only: [:index, :show, :update]
    resources "/conversation-parts", ConversationPartController, only: [:index, :show, :create]
    resources "/donation-goals", DonationGoalController, only: [:create, :update, :delete]
    post "/oauth/github", UserController, :github_oauth
    resources "/github-app-installations", GithubAppInstallationController, only: [:create]
    resources "/github-events", GithubEventController, only: [:index, :show, :update]
    resources "/github-repos", GithubRepoController, only: [:update]
    resources "/messages", MessageController, only: [:index, :show, :create]
    resources "/organization-github-app-installations", OrganizationGithubAppInstallationController, only: [:create, :delete]
    resources "/organizations", OrganizationController, only: [:create, :update]
    resources "/organization-invites", OrganizationInviteController, only: [:create, :update]
    resources "/previews", PreviewController, only: [:create]
    resources "/project-categories", ProjectCategoryController, only: [:create, :delete]
    resources "/project-skills", ProjectSkillController, only: [:create, :delete]
    resources "/project-users", ProjectUserController, only: [:create, :update, :delete]
    resources "/projects", ProjectController, only: [:create, :update]
    resources "/role-skills", RoleSkillController, only: [:create, :delete]
    resources "/roles", RoleController, only: [:create]
    resources "/skills", SkillController, only: [:create]
    resources "/stripe-connect-accounts", StripeConnectAccountController, only: [:show, :create, :update]
    resources "/stripe-connect-plans", StripeConnectPlanController, only: [:show, :create]
    resources "/stripe-connect-subscriptions", StripeConnectSubscriptionController, only: [:show, :create]
    resources "/stripe-platform-cards", StripePlatformCardController, only: [:show, :create]
    resources "/stripe-platform-customers", StripePlatformCustomerController, only: [:show, :create]
    resources "/task-skills", TaskSkillController, only: [:create, :delete]
    resources "/tasks", TaskController, only: [:create, :update]
    resources "/user-categories", UserCategoryController, only: [:create, :delete]
    resources "/user-roles", UserRoleController, only: [:create, :delete]
    resources "/user-skills", UserSkillController, only: [:create, :delete]
    resources "/user-tasks", UserTaskController, only: [:create, :update, :delete]
    resources "/users", UserController, only: [:update]
  end

  scope "/", CodeCorpsWeb, host: "api." do
    pipe_through [:api, :bearer_auth, :current_user, :tracking]

    post "/token", TokenController, :create
    post "/token/refresh", TokenController, :refresh
    post "/password/reset", PasswordResetController, :reset_password

    resources "/categories", CategoryController, only: [:index, :show]
    resources "/comments", CommentController, only: [:index, :show]
    resources "/donation-goals", DonationGoalController, only: [:index, :show]
    resources "/github-app-installations", GithubAppInstallationController, only: [:index, :show]
    resources "/github-issues", GithubIssueController, only: [:index, :show]
    resources "/github-pull-requests", GithubPullRequestController, only: [:index, :show]
    resources "/github-repos", GithubRepoController, only: [:index, :show]
    resources "/organization-github-app-installations", OrganizationGithubAppInstallationController, only: [:index, :show]
    resources "/organizations", OrganizationController, only: [:index, :show]
    resources "/organization-invites", OrganizationInviteController, only: [:index, :show]
    post "/password/forgot", PasswordController, :forgot_password
    resources "/project-categories", ProjectCategoryController, only: [:index, :show]
    resources "/project-skills", ProjectSkillController, only: [:index, :show]
    resources "/project-users", ProjectUserController, only: [:index, :show]
    resources "/projects", ProjectController, only: [:index, :show] do
      resources "/task-lists", TaskListController, only: [:index, :show]
      get "/tasks/:number", TaskController, :show
      resources "/tasks", TaskController, only: [:index]
    end
    resources "/role-skills", RoleSkillController, only: [:index, :show]
    resources "/roles", RoleController, only: [:index, :show]
    resources "/skills", SkillController, only: [:index, :show]
    resources "/task-lists", TaskListController, only: [:index, :show] do
      resources "/tasks", TaskController, only: [:index]
      get "/tasks/:number", TaskController, :show
    end
    resources "/task-skills", TaskSkillController, only: [:index, :show]
    resources "/tasks", TaskController, only: [:index, :show]
    resources "/user-categories", UserCategoryController, only: [:index, :show]
    resources "/user-roles", UserRoleController, only: [:index, :show]
    resources "/user-skills", UserSkillController, only: [:index, :show]
    resources "/user-tasks", UserTaskController, only: [:index, :show]
    get "/users/email_available", UserController, :email_available
    get "/users/username_available", UserController, :username_available
    resources "/users", UserController, only: [:index, :show, :create]
    get "/:slug", SluggedRouteController, :show
    get "/:slug/projects", ProjectController, :index
    get "/:slug/:project_slug", ProjectController, :show
  end
end
