defmodule CodeCorps.Router do
  use CodeCorps.Web, :router

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

  pipeline :with_token do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
    plug CodeCorps.Plug.CurrentUser
  end

  scope "/", CodeCorps do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through :api

    post "/login", AuthController, :create

    resources "/categories", CategoryController, only: [:index, :show]
    resources "/comments", CommentController, only: [:show]

    resources "/organizations", OrganizationController, only: [:index, :show] do
      resources "/memberships", OrganizationMembershipController, only: [:index]
    end

    resources "/organization-memberships", OrganizationMembershipController, only: [:index, :show]

    resources "/posts", PostController, only: [:index, :show] do
      resources "/comments", CommentController, only: [:index, :show]
    end

    resources "/projects", ProjectController, only: [:index, :show] do
      resources "/posts", PostController, only: [:index, :show]
    end

    resources "/project-skills", ProjectSkillController, only: [:index, :show]
    resources "/roles", RoleController, only: [:index, :show]
    resources "/skills", SkillController, only: [:index, :show]
    get "/users/email_available", UserController, :email_available
    get "/users/username_available", UserController, :username_available
    resources "/users", UserController, only: [:index, :show, :create]
    resources "/user-categories", UserCategoryController, only: [:index, :show]
    resources "/user-skills", UserSkillController, only: [:index, :show]
    resources "/role-skills", RoleSkillController, only: [:index, :show]
    get "/:slug", SluggedRouteController, :show
    get "/:slug/projects", ProjectController, :index
    get "/:slug/:project_slug", ProjectController, :show
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through [:api, :with_token]

    delete "/logout", AuthController, :delete

    resources "/categories", CategoryController, only: [:create, :update]
    resources "/comments", CommentController, only: [:create, :update]
    resources "/organizations", OrganizationController, only: [:create, :update]
    resources "/organization-memberships", OrganizationMembershipController, only: [:create, :update, :delete]
    resources "/posts", PostController, only: [:create, :update]
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
