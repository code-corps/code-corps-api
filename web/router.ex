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

  scope "/", CodeCorps do
    pipe_through [:logging, :browser] # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :stripe_webhooks]

    post "/webhooks/stripe/connect", StripeConnectEventsController, :create
    post "/webhooks/stripe/platform", StripePlatformEventsController, :create
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :api, :bearer_auth, :ensure_auth, :current_user]

    resources "/categories", CategoryController, only: [:create, :update]
    resources "/comments", CommentController, only: [:create, :update]
    resources "/donation-goals", DonationGoalController, only: [:create, :update, :delete]
    resources "/organizations", OrganizationController, only: [:create, :update]
    resources "/organization-memberships", OrganizationMembershipController, only: [:create, :update, :delete]
    resources "/previews", PreviewController, only: [:create]
    resources "/projects", ProjectController, only: [:create, :update]
    get "/projects/:id/stripe-auth", StripeAuthController, :stripe_auth
    resources "/project-categories", ProjectCategoryController, only: [:create, :delete]
    resources "/project-skills", ProjectSkillController, only: [:create, :delete]
    resources "/roles", RoleController, only: [:create]
    resources "/role-skills", RoleSkillController, only: [:create, :delete]
    resources "/skills", SkillController, only: [:create]
    resources "/stripe-connect-accounts", StripeConnectAccountController, only: [:show, :create]
    resources "/stripe-connect-plans", StripeConnectPlanController, only: [:show, :create]
    resources "/stripe-connect-subscriptions", StripeConnectSubscriptionController, only: [:show, :create]
    resources "/stripe-platform-cards", StripePlatformCardController, only: [:show, :create]
    resources "/stripe-platform-customers", StripePlatformCustomerController, only: [:show, :create]
    resources "/tasks", TaskController, only: [:create, :update]
    resources "/users", UserController, only: [:update]
    resources "/user-categories", UserCategoryController, only: [:create, :delete]
    resources "/user-roles", UserRoleController, only: [:create, :delete]
    resources "/user-skills", UserSkillController, only: [:create, :delete]
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:logging, :api, :bearer_auth, :current_user]

    post "/token", TokenController, :create
    post "/token/refresh", TokenController, :refresh

    resources "/categories", CategoryController, only: [:index, :show]
    resources "/comments", CommentController, only: [:index, :show]
    resources "/donation-goals", DonationGoalController, only: [:index, :show]
    resources "/organizations", OrganizationController, only: [:index, :show]
    resources "/organization-memberships", OrganizationMembershipController, only: [:index, :show]
    resources "/projects", ProjectController, only: [:index, :show] do
      resources "/task-lists", TaskListController, only: [:index, :show]
      resources "/tasks", TaskController, only: [:index, :show]
    end
    resources "/project-categories", ProjectCategoryController, only: [:index, :show]
    resources "/project-skills", ProjectSkillController, only: [:index, :show]
    resources "/roles", RoleController, only: [:index, :show]
    resources "/role-skills", RoleSkillController, only: [:index, :show]
    resources "/skills", SkillController, only: [:index, :show]
    resources "/task-lists", TaskListController, only: [:index, :show] do
      resources "/tasks", TaskController, only: [:index, :show]
    end
    resources "/tasks", TaskController, only: [:index, :show]
    get "/users/email_available", UserController, :email_available
    get "/users/username_available", UserController, :username_available
    resources "/users", UserController, only: [:index, :show, :create]
    resources "/user-categories", UserCategoryController, only: [:index, :show]
    resources "/user-roles", UserRoleController, only: [:index, :show]
    resources "/user-skills", UserSkillController, only: [:index, :show]
    get "/:slug", SluggedRouteController, :show
    get "/:slug/projects", ProjectController, :index
    get "/:slug/:project_slug", ProjectController, :show
  end
end
