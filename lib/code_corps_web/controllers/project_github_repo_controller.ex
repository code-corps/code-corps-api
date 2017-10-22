defmodule CodeCorpsWeb.ProjectGithubRepoController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{ProjectGithubRepo, User, Helpers.Query}

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
      conn |> put_status(:created) |> render("show.json-api", data: project_github_repo)
    end
  end

  @spec delete(Plug.Conn.t, map) :: Conn.t
  def delete(%Conn{} = conn, %{"id" => id} = params) do
    with %ProjectGithubRepo{} = project_github_repo <- ProjectGithubRepo |> Repo.get(id),
         %User{} = current_user <- conn |> Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:delete, project_github_repo, params),
         {:ok, _project_github_repo} <- project_github_repo |> Repo.delete do
      conn |> send_resp(:no_content, "")
    end
  end

  @spec create_project_repo_changeset(map) :: Ecto.Changeset.t
  defp create_project_repo_changeset(params) do
    %ProjectGithubRepo{}
    |> ProjectGithubRepo.create_changeset(params)
  end
end
