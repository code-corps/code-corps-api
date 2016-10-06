defmodule CodeCorps.UserRoleController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller

  import CodeCorps.AuthenticationHelpers, only: [authorize: 2, authorized?: 1]

  alias CodeCorps.UserRole
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: UserRole, only: [:delete]

  def index(conn, params) do
    user_roles =
      UserRole
      |> UserRole.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: user_roles)
  end

  def create(conn, %{"data" => data = %{"type" => "user-role"}}) do
    changeset = UserRole.changeset(%UserRole{}, Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.insert(changeset) do
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
    else
      conn
    end
  end

  def show(conn, %{"id" => id}) do
    user_role =
      UserRole
      |> Repo.get!(id)
    render(conn, "show.json-api", data: user_role)
  end

  def delete(conn, %{"id" => id}) do
    user_role =
      UserRole
      |> Repo.get!(id)
      |> Repo.delete!

    conn
    |> @analytics.track(:removed, user_role)
    |> send_resp(:no_content, "")
  end
end
