defmodule CodeCorps.UserCategoryController do
  use CodeCorps.Web, :controller

  import CodeCorps.ControllerHelpers

  alias CodeCorps.UserCategory
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
      user_categories =
        case params do
          %{"filter" => %{"id" => id_list}} ->
            ids = id_list |> coalesce_id_string
            UserCategory
            |> preload([:user, :category])
            |> where([p], p.id in ^ids)
            |> Repo.all
         %{} ->
            UserCategory
            |> preload([:user, :category])
            |> Repo.all
        end
      render(conn, "index.json-api", data: user_categories)
    end

    def create(conn, %{"data" => data = %{"type" => "user-category"}}) do
      changeset = UserCategory.changeset(%UserCategory{}, Params.to_attributes(data))

      case Repo.insert(changeset) do
        {:ok, user_category} ->
          conn
          |> put_status(:created)
          |> put_resp_header("location", user_category_path(conn, :show, user_category))
          |> render("show.json-api", data: user_category |> Repo.preload([:user, :category]))
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
      end
    end

    def show(conn, %{"id" => id}) do
      user_category =
        UserCategory
        |> preload([:user, :category])
        |> Repo.get!(id)
      render(conn, "show.json-api", data: user_category)
    end

    def delete(conn, %{"id" => id}) do
      UserCategory |> Repo.get!(id) |> Repo.delete!
      conn |> send_resp(:no_content, "")
    end
end
