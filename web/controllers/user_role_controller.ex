defmodule CodeCorps.UserRoleController do
  use CodeCorps.Web, :controller
  alias CodeCorps.UserRole

  @analytics Application.get_env(:code_corps, :analytics)

  plug :load_resource, model: UserRole, only: [:show], preload: [:user, :role]
  plug :load_and_authorize_changeset, model: UserRole, only: [:create]
  plug :load_and_authorize_resource, model: UserRole, only: [:delete]

  def index(conn, params) do
    user_roles =
      UserRole
      |> UserRole.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: user_roles)
  end

  def create(conn, %{"data" => %{"type" => "user-role"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, user_role} ->
        conn
        |> @analytics.track(:added, user_role)
        |> put_status(:created)
        |> render("show.json-api", data: user_role)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.user_role)
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.user_role |> Repo.delete!

    conn
    |> @analytics.track(:removed, conn.assigns.user_role)
    |> send_resp(:no_content, "")
  end
end
