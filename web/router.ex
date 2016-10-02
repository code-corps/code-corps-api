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
  end

  pipeline :analytics_identify do
    plug CodeCorps.Plug.AnalyticsIdentify
  end

  scope "/", CodeCorps do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:api, :bearer_auth, :current_user, :analytics_identify]

    post "/token", TokenController, :create
    post "/token/refresh", TokenController, :refresh

    resources "/categories", CategoryController, only: [:index, :show]
    resources "/comments", CommentController, only: [:show]

    resources "/organizations", OrganizationController, only: [:index, :show] do
      resources "/memberships", OrganizationMembershipController, only: [:index]
    end

    resources "/organization-memberships", OrganizationMembershipController, only: [:index, :show]

    resources "/tasks", TaskController, only: [:index, :show] do
      resources "/comments", CommentController, only: [:index, :show]
    end

    resources "/projects", ProjectController, only: [:index, :show] do
      resources "/tasks", TaskController, only: [:index, :show]
    end

    resources "/project-categories", ProjectCategoryController, only: [:index, :show]
    resources "/project-skills", ProjectSkillController, only: [:index, :show]
    resources "/roles", RoleController, only: [:index, :show]
    resources "/skills", SkillController, only: [:index, :show]
    get "/users/email_available", UserController, :email_available
    get "/users/username_available", UserController, :username_available
    resources "/users", UserController, only: [:index, :show, :create]
    resources "/user-categories", UserCategoryController, only: [:index, :show]
    resources "/user-roles", UserRoleController, only: [:index, :show]
    resources "/user-skills", UserSkillController, only: [:index, :show]
    resources "/role-skills", RoleSkillController, only: [:index, :show]
    get "/:slug", SluggedRouteController, :show
    get "/:slug/projects", ProjectController, :index
    get "/:slug/:project_slug", ProjectController, :show
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:api, :bearer_auth, :ensure_auth, :current_user, :analytics_identify]

    resources "/categories", CategoryController, only: [:create, :update]
    resources "/comments", CommentController, only: [:create, :update]
    resources "/organizations", OrganizationController, only: [:create, :update]
    resources "/organization-memberships", OrganizationMembershipController, only: [:create, :update, :delete]
    resources "/tasks", TaskController, only: [:create, :update]
    resources "/previews", PreviewController, only: [:create]
    resources "/projects", ProjectController, only: [:create, :update]
    resources "/project-categories", ProjectCategoryController, only: [:create, :delete]
    resources "/project-skills", ProjectSkillController, only: [:create, :delete]
    resources "/roles", RoleController, only: [:create]
    resources "/skills", SkillController, only: [:create]
    resources "/users", UserController, only: [:update]
    resources "/user-categories", UserCategoryController, only: [:create, :delete]
    resources "/user-roles", UserRoleController, only: [:create, :delete]
    resources "/user-skills", UserSkillController, only: [:create, :delete]
    resources "/role-skills", RoleSkillController, only: [:create, :delete]
  end
end
