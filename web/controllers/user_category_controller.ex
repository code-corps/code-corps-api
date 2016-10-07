defmodule CodeCorps.UserCategoryController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller

  alias CodeCorps.UserCategory

  plug :load_resource, model: UserCategory, only: [:show], preload: [:user, :category]
  plug :load_and_authorize_changeset, model: UserCategory, only: [:create]
  plug :load_and_authorize_resource, model: UserCategory, only: [:delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    user_categories =
      UserCategory
      |> UserCategory.index_filters(params)
      |> Repo.all

    render(conn, "index.json-api", data: user_categories)
  end

  def create(conn, %{"data" => %{"type" => "user-category"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, user_category} ->
        conn
        |> @analytics.track(:added, user_category)
        |> put_status(:created)
        |> put_resp_header("location", user_category_path(conn, :show, user_category))
        |> render("show.json-api", data: user_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    render(conn, "show.json-api", data: conn.assigns.user_category)
  end

  def delete(conn, %{"id" => _id}) do
    conn.assigns.user_category |> Repo.delete!

    conn
    |> @analytics.track(:removed, conn.assigns.user_category)
    |> send_resp(:no_content, "")
  end
end
