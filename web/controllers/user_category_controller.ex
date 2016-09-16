defmodule CodeCorps.UserCategoryController do
  @analytics Application.get_env(:code_corps, :analytics)
  
  use CodeCorps.Web, :controller

  import CodeCorps.AuthenticationHelpers, only: [authorize: 2, authorized?: 1]

  alias CodeCorps.UserCategory
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: UserCategory, only: [:delete]
  plug :scrub_params, "data" when action in [:create]

  def index(conn, params) do
    user_categories =
      UserCategory
      |> UserCategory.index_filters(params)
      |> preload([:user, :category])
      |> Repo.all

    render(conn, "index.json-api", data: user_categories)
  end

  def create(conn, %{"data" => data = %{"type" => "user-category"}}) do
    changeset = UserCategory.changeset(%UserCategory{}, Params.to_attributes(data))

    conn = conn |> authorize(changeset)

    if conn |> authorized? do
      case Repo.insert(changeset) do
        {:ok, user_category} ->
          user_category = user_category |> Repo.preload([:user, :category])
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
    else
      conn
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
    user_category =
      UserCategory
      |> preload([:user, :category])
      |> Repo.get!(id)
      |> Repo.delete!

    conn
    |> @analytics.track(:removed, user_category)
    |> send_resp(:no_content, "")
  end
end
