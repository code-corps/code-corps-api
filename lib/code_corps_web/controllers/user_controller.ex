defmodule CodeCorpsWeb.UserController do
  use CodeCorpsWeb, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2, user_filter: 2, limit_filter: 2]

  alias CodeCorps.{Category, Services.UserService, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug :login, only: [:create]
  plug JaResource, except: [:create, :update]

  def handle_index(_conn, params) do
    User
    |> user_filter(params)
    |> limit_filter(params)
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, params),
         {:ok, %User{} = user} <- %User{} |> User.registration_changeset(params) |> Repo.insert
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
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Differs from other resources by path: `/oauth/github`
  """
  def github_oauth(conn, %{"code" => code, "state" => state}) do
    current_user = Guardian.Plug.current_resource(conn)
    with {:ok, user} <- GitHub.User.connect(current_user, code, state)
    do
      conn |> render("show.json-api", data: user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorpsWeb.ChangesetView, "error.json-api", changeset: changeset)
      {:error, _error} ->
        conn
        |> put_status(:internal_server_error)
        |> render(CodeCorpsWeb.ErrorView, "500.json-api")
    end
  end

  def email_available(conn, %{"email" => email}) do
    hash = User.check_email_availability(email)
    conn |> json(hash)
  end

  def username_available(conn, %{"username" => username}) do
    hash = User.check_username_availability(username)
    conn |> json(hash)
  end

  defp login(conn, _opts) do
    Plug.Conn.register_before_send(conn, &do_login(&1))
  end

  defp do_login(conn), do: Plug.Conn.assign(conn, :current_user, conn.assigns[:data])
end
