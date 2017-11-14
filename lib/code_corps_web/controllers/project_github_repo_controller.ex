defmodule CodeCorpsWeb.ProjectGithubRepoController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Analytics.SegmentTracker, Processor, ProjectGithubRepo, User, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with organization_installations <- ProjectGithubRepo |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: organization_installations)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %ProjectGithubRepo{} = project_github_repo <- ProjectGithubRepo |> Repo.get(id) do
      conn |> render("show.json-api", data: project_github_repo)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %ProjectGithubRepo{}, params),
         {:ok, %ProjectGithubRepo{} = project_github_repo} <- create_project_repo_changeset(params) |> Repo.insert do

      Processor.process(fn ->
        CodeCorps.GitHub.Sync.sync_project_github_repo(project_github_repo)
      end)

      current_user |> track_created(project_github_repo)

      conn |> put_status(:created) |> render("show.json-api", data: project_github_repo)
    end
  end

  @spec delete(Plug.Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = params) do
    with %ProjectGithubRepo{} = project_github_repo <- ProjectGithubRepo |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:delete, project_github_repo, params),
         {:ok, project_github_repo} <- project_github_repo |> Repo.delete do

      current_user |> track_deleted(project_github_repo)

      conn |> send_resp(:no_content, "")
    end
  end

  @spec create_project_repo_changeset(map) :: Ecto.Changeset.t
  defp create_project_repo_changeset(params) do
    %ProjectGithubRepo{}
    |> ProjectGithubRepo.create_changeset(params)
  end

  @spec track_created(User.t, ProjectGithubRepo.t) :: any
  defp track_created(%User{id: user_id}, %ProjectGithubRepo{} = project_github_repo) do
    user_id |> SegmentTracker.track("Connected GitHub Repo to Project", project_github_repo)
  end

  @spec track_deleted(User.t, ProjectGithubRepo.t) :: any
  defp track_deleted(%User{id: user_id}, %ProjectGithubRepo{} = project_github_repo) do
    user_id |> SegmentTracker.track("Disconnected GitHub Repo from Project", project_github_repo)
  end
end
