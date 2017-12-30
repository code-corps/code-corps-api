defmodule CodeCorpsWeb.UserController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Analytics,
    GitHub,
    Helpers.Query,
    Services.UserService,
    User,
    Accounts
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    users =
      User
      |> Query.id_filter(params)
      |> Query.limit_filter(params)
      |> Query.user_filter(params)
      |> Accounts.Users.project_filter(params)
      |> Repo.all()
      |> preload()

    conn |> render("index.json-api", data: users)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = user <- User |> Repo.get(id) |> preload() do
      conn |> render("show.json-api", data: user)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with {:ok, %User{} = user} <- %User{} |> User.registration_changeset(params) |> Repo.insert(),
         user <- preload(user)
    do
      maybe_alias(user, params)
      conn |> put_status(:created) |> render("show.json-api", data: user)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = user <- User |> Repo.get(id),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, user),
         {:ok, user, _, _} <- user |> UserService.update(params),
         user <- preload(user)
    do
       conn |> render("show.json-api", data: user)
    end
  end

  @doc """
  Differs from other resources by path: `/oauth/github`
  """
  @spec github_oauth(Conn.t, map) :: Conn.t
  def github_oauth(%Conn{} = conn, %{"code" => code, "state" => state}) do
    current_user = Guardian.Plug.current_resource(conn)
    with {:ok, user} <- GitHub.API.User.connect(current_user, code, state),
         user <- preload(user)
    do
      Analytics.SegmentTracker.track(user.id, "Connected to GitHub", user)
      conn |> render("show.json-api", data: user)
    end
  end

  @spec email_available(Conn.t, map) :: Conn.t
  def email_available(%Conn{} = conn, %{"email" => email}) do
    hash = User.check_email_availability(email)
    conn |> json(hash)
  end

  @spec username_available(Conn.t, map) :: Conn.t
  def username_available(%Conn{} = conn, %{"username" => username}) do
    hash = User.check_username_availability(username)
    conn |> json(hash)
  end

  @preloads [
    :categories, :github_app_installations, :organizations, :project_users,
    :slugged_route, :stripe_connect_subscriptions, :stripe_platform_card,
    :stripe_platform_customer, :user_categories, :user_roles, :user_skills
  ]

  def preload(data) do
    Repo.preload(data, @preloads)
  end

  @spec maybe_alias(User.t, map) :: any
  defp maybe_alias(%User{id: id}, %{"previous_id" => previous_id}) do
    Analytics.SegmentTracker.alias(id, previous_id)
  end
  defp maybe_alias(_user, _params), do: nil
end
