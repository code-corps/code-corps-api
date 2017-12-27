defmodule CodeCorpsWeb.UserTaskController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Analytics.SegmentTracker,
    UserTask,
    User,
    Helpers.Query
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with user_tasks <- UserTask |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: user_tasks)
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
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserTask{}, params),
      {:ok, %UserTask{} = user_task} <- %UserTask{} |> UserTask.create_changeset(params) |> Repo.insert
    do
      current_user |> track_assigned(user_task)

      conn |> put_status(:created) |> render("show.json-api", data: user_task)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %UserTask{} = user_task <- UserTask |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, user_task),
      {:ok, %UserTask{} = user_task} <- user_task |> UserTask.update_changeset(params) |> Repo.update
    do
      current_user |> track_assigned(user_task)

      conn |> render("show.json-api", data: user_task)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %UserTask{} = user_task <- UserTask |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, user_task),
      {:ok, %UserTask{} = _user_task} <- user_task |> Repo.delete
    do
      current_user |> track_unassigned(user_task)

      conn |> send_resp(:no_content, "")
    end
  end

  @spec track_assigned(User.t, UserTask.t) :: any
  defp track_assigned(%User{id: user_id}, %UserTask{user_id: assigned_user_id} = user_task)
    when user_id == assigned_user_id, do: SegmentTracker.track(user_id, "Assigned Task to Self", user_task)
  defp track_assigned(%User{id: user_id}, %UserTask{} = user_task),
    do: SegmentTracker.track(user_id, "Assigned Task to Someone Else", user_task)

  @spec track_unassigned(User.t, UserTask.t) :: any
  defp track_unassigned(%User{id: user_id}, %UserTask{user_id: assigned_user_id} = user_task)
    when user_id == assigned_user_id, do: SegmentTracker.track(user_id, "Unassigned Task from Self", user_task)
  defp track_unassigned(%User{id: user_id}, %UserTask{} = user_task),
    do: SegmentTracker.track(user_id, "Unassigned Task from Someone Else", user_task)
end
