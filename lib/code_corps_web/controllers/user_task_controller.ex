defmodule CodeCorpsWeb.UserTaskController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{UserTask, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with categories <- UserTask |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: categories)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %UserTask{} = user_task <- UserTask |> Repo.get(id) do
      conn |> render("show.json-api", data: user_task)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserTask{}, params),
      {:ok, %UserTask{} = user_task} <- %UserTask{} |> UserTask.create_changeset(params) |> Repo.insert
    do
      conn |> put_status(:created) |> render("show.json-api", data: user_task)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %UserTask{} = user_task <- UserTask |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, user_task),
      {:ok, %UserTask{} = user_task} <- user_task |> UserTask.update_changeset(params) |> Repo.update
    do
      conn |> render("show.json-api", data: user_task)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %UserTask{} = user_task <- UserTask |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, user_task),
      {:ok, %UserTask{} = _user_task} <- user_task |> Repo.delete
    do
      conn |> send_resp(:no_content, "")
    end
  end
end
