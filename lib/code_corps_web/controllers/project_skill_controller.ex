defmodule CodeCorpsWeb.ProjectSkillController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Analytics.SegmentTracker, ProjectSkill, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with project_skills <- ProjectSkill |> Query.id_filter(params) |> Repo.all |> preload() do
      conn |> render("index.json-api", data: project_skills)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %ProjectSkill{} = project_skill <- ProjectSkill |> Repo.get(id) |> preload() do
      conn |> render("show.json-api", data: project_skill)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %ProjectSkill{}, params),
         {:ok, %ProjectSkill{} = project_skill} <- %ProjectSkill{} |> ProjectSkill.create_changeset(params) |> Repo.insert(),
         project_skill <- preload(project_skill)
    do
      current_user.id |> SegmentTracker.track("Added Project Skill", project_skill)
      conn |> put_status(:created) |> render("show.json-api", data: project_skill)
    end
  end

  @spec delete(Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = _params) do
    with %ProjectSkill{} = project_skill <- ProjectSkill |> Repo.get(id),
      %User{} = current_user <- conn |> Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:delete, project_skill),
      {:ok, %ProjectSkill{} = project_skill} <- project_skill |> Repo.delete
    do
      current_user.id |> SegmentTracker.track("Removed Project Skill", project_skill)
      conn |> Conn.assign(:project_skill, project_skill) |> send_resp(:no_content, "")
    end
  end

  @preloads [
    :skill
  ]

  def preload(data) do
    Repo.preload(data, @preloads)
  end
end
