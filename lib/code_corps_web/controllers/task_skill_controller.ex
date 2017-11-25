defmodule CodeCorpsWeb.TaskSkillController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Analytics.SegmentTracker,
    Helpers.Query,
    TaskSkill,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with task_skills <- TaskSkill |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: task_skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %TaskSkill{} = task_skill <- TaskSkill |> Repo.get(id) do
      conn |> render("show.json-api", data: task_skill)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %TaskSkill{}, params),
         {:ok, %TaskSkill{} = task_skill} <- %TaskSkill{} |> TaskSkill.create_changeset(params) |> Repo.insert
    do
      SegmentTracker.track(current_user.id, "Added Task Skill", task_skill)
      conn |> put_status(:created) |> render("show.json-api", data: task_skill)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %TaskSkill{} = task_skill <- TaskSkill |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, task_skill),
      {:ok, %TaskSkill{} = _task_skill} <- task_skill |> Repo.delete
    do
      SegmentTracker.track(current_user.id, "Removed Task Skill", task_skill)
      conn |> Conn.assign(:task_skill, task_skill) |> send_resp(:no_content, "")
    end
  end
end
