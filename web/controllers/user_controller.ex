defmodule CodeCorps.UserController do
  use CodeCorps.Web, :controller

  import CodeCorps.ControllerHelpers

  alias CodeCorps.User
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, params) do
    users =
      case params do
        %{"filter" => %{"id" => id_list}} ->
          ids = id_list |> coalesce_id_string
          User
          |> preload([:slugged_route, :categories, :roles])
          |> where([p], p.id in ^ids)
          |> Repo.all
        %{} ->
          User
          |> preload([:slugged_route, :categories, :roles])
          |> Repo.all
      end

    render(conn, "index.json-api", data: users)
  end

  def create(conn, %{"data" => data = %{"type" => "user", "attributes" => _user_params}}) do
    changeset = User.registration_changeset(%User{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, user} ->
        user = Repo.preload(user, [:slugged_route, :categories, :roles])

        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user =
      User
      |> preload([:slugged_route, :categories, :roles])
      |> Repo.get!(id)
  render(conn, "show.json-api", data: user)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "user", "attributes" => _user_params}}) do
    user =
      User
      |> preload([:slugged_route, :categories, :roles])
      |> Repo.get!(id)

    changeset = User.update_changeset(user, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def email_available(conn, %{"email" => email}) do
    hash = User.check_email_availability(email)

    conn
    |> json(hash)
  end

  def username_available(conn, %{"username" => username}) do
    hash = User.check_username_availability(username)

    conn
    |> json(hash)
  end
end
