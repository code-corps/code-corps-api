defmodule CodeCorps.Router do
  use CodeCorps.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :logging do
    plug Timber.ContextPlug
    plug Timber.EventPlug
  end

  pipeline :api do
    plug :accepts, ["json-api", "json"]
    plug JaSerializer.Deserializer
  end

  pipeline :bearer_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :current_user do
    plug CodeCorps.Plug.CurrentUser
    plug CodeCorps.Plug.SetSentryUserContext
    plug CodeCorps.Plug.AnalyticsIdentify
  end

  pipeline :stripe_webhooks do
    plug :accepts, ["json"]
  end

  pipeline :tracking do
    plug CodeCorps.Plug.Segment
  end

  scope "/", CodeCorps do
    pipe_through [:logging, :browser] # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :stripe_webhooks]

    post "/webhooks/stripe/connect", StripeConnectEventsController, :create
    post "/webhooks/stripe/platform", StripePlatformEventsController, :create
    post "/webhooks/github", GitHubEventsController, :create, as: :github_events
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :api, :bearer_auth, :ensure_auth, :current_user, :tracking]

    resources "/categories", CategoryController, only: [:create, :update]
    resources "/comments", CommentController, only: [:create, :update]
    resources "/donation-goals", DonationGoalController, only: [:create, :update, :delete]
    post "/oauth/github", UserController, :github_oauth
    resources "/github-app-installations", GithubAppInstallationController, only: [:create, :update]
    resources "/organizations", OrganizationController, only: [:create, :update]
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

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :api, :bearer_auth, :current_user, :tracking]

    post "/token", TokenController, :create
    post "/token/refresh", TokenController, :refresh
    post "/password/reset", PasswordResetController, :reset_password

    resources "/categories", CategoryController, only: [:index, :show]
    resources "/comments", CommentController, only: [:index, :show]
    resources "/donation-goals", DonationGoalController, only: [:index, :show]
    resources "/github-app-installations", GithubAppInstallationController, only: [:index, :show]
    resources "/organizations", OrganizationController, only: [:index, :show]
    post "/password/forgot", PasswordController, :forgot_password
    resources "/project-categories", ProjectCategoryController, only: [:index, :show]
    resources "/project-skills", ProjectSkillController, only: [:index, :show]
    resources "/project-users", ProjectUserController, only: [:index, :show]
    resources "/projects", ProjectController, only: [:index, :show] do
      resources "/task-lists", TaskListController, only: [:index, :show]
      resources "/tasks", TaskController, only: [:index, :show]
    end
    resources "/role-skills", RoleSkillController, only: [:index, :show]
    resources "/roles", RoleController, only: [:index, :show]
    resources "/skills", SkillController, only: [:index, :show]
    resources "/task-lists", TaskListController, only: [:index, :show] do
      resources "/tasks", TaskController, only: [:index, :show]
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
