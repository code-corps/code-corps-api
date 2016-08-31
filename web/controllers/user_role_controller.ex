defmodule CodeCorps.UserRoleController do
  use CodeCorps.Web, :controller

  alias CodeCorps.UserRole
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: UserRole, only: [:delete]

  def create(conn, %{"data" => data = %{"type" => "user-role"}}) do
    changeset = UserRole.changeset(%UserRole{}, Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.insert(changeset) do
        {:ok, user_role} ->
          conn
          |> put_status(:created)
          |> render("show.json-api", data: user_role |> Repo.preload([:user, :role]))
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      end
    else
      conn
    end
  end

  def delete(conn, %{"id" => id}) do
    UserRole |> Repo.get!(id) |> Repo.delete!
    conn |> send_resp(:no_content, "")
  end

  defp authorize(conn, changeset) do
    conn
    |> assign(:changeset, changeset)
    |> Canary.Plugs.authorize_resource(model: changeset)
  end
  defp authorized?(conn), do: conn |> Map.get(:assigns) |> Map.get(:authorized)
end
