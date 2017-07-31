defmodule CodeCorps.UserController do
  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2, user_filter: 2, limit_filter: 2]

  alias CodeCorps.GitHub
  alias CodeCorps.Services.UserService
  alias CodeCorps.User

  plug :load_and_authorize_resource, model: User, only: [:update]
  plug JaResource
  plug :login, only: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_index(_conn, params) do
    User
    |> user_filter(params)
    |> limit_filter(params)
  end

  def handle_create(_conn, attributes) do
    %User{} |> User.registration_changeset(attributes)
  end

  def handle_update(_conn, record, attributes) do
    with {:ok, user, _, _} <- UserService.update(record, attributes)
    do
      {:ok, user}
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
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      {:error, _error} ->
        conn
        |> put_status(:internal_server_error)
        |> render(CodeCorps.ErrorView, "500.json-api")
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
