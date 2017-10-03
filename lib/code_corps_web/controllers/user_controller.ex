defmodule CodeCorpsWeb.UserController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Helpers.Query, Services.UserService, User}
  alias CodeCorps.GitHub

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with users <- User |> Query.id_filter(params) |> Query.limit_filter(params) |> Query.user_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: users)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %User{} = user <- User |> Repo.get(id) do
      conn |> render("show.json-api", data: user)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with {:ok, %User{} = user} <- %User{} |> User.registration_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: user)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %User{} = user <- User |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, user),
         {:ok, user, _, _} <- user |> UserService.update(params)
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
    with {:ok, user} <- GitHub.User.connect(current_user, code, state)
    do
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

end
