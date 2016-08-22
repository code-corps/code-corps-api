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
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", CodeCorps do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", CodeCorps, host: "api." do
    pipe_through :api

    post "/login", AuthController, :create
    delete "/logout", AuthController, :delete

    resources "/categories", CategoryController, only: [:index, :show, :create, :update]

    resources "/comments", CommentController, only: [:index, :show, :create, :update]

    resources "/organizations", OrganizationController, only: [:index, :show, :create, :update] do
      resources "/memberships", OrganizationMembershipController, only: [:index]
    end

    resources "/organization-memberships", OrganizationMembershipController, only: [:index, :show, :create, :update, :delete]

    resources "/posts", PostController, only: [:create, :index, :show, :update] do
      resources "/comments", CommentController, only: [:index, :show]
    end

    resources "/previews", PreviewController, only: [:create]

    resources "/projects", ProjectController, only: [:index, :show, :create, :update] do
      resources "/posts", PostController, only: [:index, :show]
    end

    resources "/project_categories", ProjectCategoryController, only: [:create, :delete]

    resources "/roles", RoleController, only: [:create, :index, :show]

    resources "/skills", SkillController, only: [:create, :index, :show]

    get "/users/email_available", UserController, :email_available
    get "/users/username_available", UserController, :username_available
    resources "/users", UserController, only: [:index, :show, :create, :update]

    resources "/user-roles", UserRoleController, only: [:create, :delete]
    resources "/user-skills", UserSkillController, only: [:index, :show, :create, :delete]
    resources "/role-skills", RoleSkillController, only: [:index, :show, :create, :delete]

    get "/:slug", SluggedRouteController, :show
    get "/:slug/projects", ProjectController, :index
    get "/:slug/:project_slug", ProjectController, :show
  end
end
