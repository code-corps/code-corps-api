defmodule CodeCorpsWeb.TaskController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Analytics.SegmentTracker, Task, Policy, User}

  import ScoutApm.Tracing

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    tasks = Task.Query.list(params)
    tasks = preload(tasks)
    timing("JaSerializer", "render") do
      conn |> render("index.json-api", data: tasks)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{} = params) do
    with %Task{} = task <- Task.Query.find(params),
         task <- preload(task)
    do
      conn |> render("show.json-api", data: task)
    end
  end

  @spec create(Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %Task{}, params),
         {:ok, %Task{} = task} <- params |> Task.Service.create,
         task <- preload(task)
      do
      current_user |> track_created(task)
      current_user |> maybe_track_connected(task)

      conn |> put_status(:created) |> render("show.json-api", data: task)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{} = params) do
    with %Task{} = task <- Task.Query.find(params),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, task),
         {:ok, %Task{} = updated_task} <- task |> Task.Service.update(params),
         updated_task <- preload(updated_task)
      do

      current_user |> track_updated(updated_task)
      current_user |> maybe_track_connected(updated_task, task)
      current_user |> maybe_track_list_move(updated_task, task)
      current_user |> maybe_track_title_change(updated_task, task)
      current_user |> maybe_track_close(updated_task, task)
      current_user |> maybe_track_archive(updated_task, task)

      conn |> render("show.json-api", data: updated_task)
    end
  end

  @preloads [:comments, :github_pull_request, :task_skills, :user_task]

  def preload(data) do
    timing("TaskController", "preload") do
      Repo.preload(data, @preloads)
    end
  end

  # tracking

  @spec track_created(User.t, Task.t) :: any
  defp track_created(%User{id: user_id}, %Task{} = task) do
    user_id |> SegmentTracker.track("Created Task", task)
  end

  @spec track_updated(User.t, Task.t) :: any
  defp track_updated(%User{id: user_id}, %Task{} = task) do
    user_id |> SegmentTracker.track("Edited Task", task)
  end

  @spec maybe_track_connected(User.t, Task.t) :: any
  defp maybe_track_connected(
    %User{id: user_id},
    %Task{github_issue_id: issue_id} = task) when not is_nil(issue_id) do

    user_id |> SegmentTracker.track("Connected Task to GitHub", task)
  end
  defp maybe_track_connected(%User{}, %Task{}), do: :nothing

  @spec maybe_track_connected(User.t, Task.t, Task.t) :: any
  defp maybe_track_connected(
    %User{id: user_id},
    %Task{github_issue_id: new_issue_id} = task,
    %Task{github_issue_id: old_issue_id})
    when is_nil(old_issue_id) and not is_nil(new_issue_id) do

    user_id |> SegmentTracker.track("Connected Task to GitHub", task)
  end
  defp maybe_track_connected(%User{}, %Task{}, %Task{}), do: :nothing

  @spec maybe_track_list_move(User.t, Task.t, Task.t) :: any
  defp maybe_track_list_move(
    %User{id: user_id},
    %Task{task_list_id: new_list_id} = task,
    %Task{task_list_id: old_list_id}) when new_list_id != old_list_id do

    user_id |> SegmentTracker.track("Moved Task Between Lists", task)
  end
  defp maybe_track_list_move(%User{}, %Task{}, %Task{}), do: :nothing

  @spec maybe_track_title_change(User.t, Task.t, Task.t) :: any
  defp maybe_track_title_change(
    %User{id: user_id},
    %Task{title: new_title} = task,
    %Task{title: old_title}) when new_title != old_title do

    user_id |> SegmentTracker.track("Edited Task Title", task)
  end
  defp maybe_track_title_change(%User{}, %Task{}, %Task{}), do: :nothing

  @spec maybe_track_close(User.t, Task.t, Task.t) :: any
  defp maybe_track_close(
    %User{id: user_id},
    %Task{status: "closed"} = task,
    %Task{status: "open"}) do

    user_id |> SegmentTracker.track("Closed Task", task)
  end
  defp maybe_track_close(%User{}, %Task{}, %Task{}), do: :nothing

  @spec maybe_track_archive(User.t, Task.t, Task.t) :: any
  defp maybe_track_archive(
    %User{id: user_id},
    %Task{archived: true} = task,
    %Task{archived: false}) do

    user_id |> SegmentTracker.track("Archived Task", task)
  end
  defp maybe_track_archive(%User{}, %Task{}, %Task{}), do: :nothing
end
