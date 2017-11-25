defmodule CodeCorpsWeb.GithubRepoController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{
    Analytics.SegmentTracker,
    GithubRepo,
    Helpers.Query,
    Processor,
    User
  }

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with github_repos <- GithubRepo |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: github_repos)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %GithubRepo{} = github_repo <- GithubRepo |> Repo.get(id) do
      conn |> render("show.json-api", data: github_repo)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %GithubRepo{} = github_repo <- GithubRepo |> Repo.get(id),
      %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
      {:ok, :authorized} <- current_user |> Policy.authorize(:update, github_repo, params),
      {:ok, %GithubRepo{} = github_repo} <- github_repo |> GithubRepo.update_changeset(params) |> Repo.update()
    do
      github_repo |> postprocess()
      current_user |> track(github_repo)
      conn |> render("show.json-api", data: github_repo)
    end
  end

  @spec postprocess(GithubRepo.t) :: any
  defp postprocess(%GithubRepo{project_id: nil}), do: nil
  defp postprocess(%GithubRepo{} = github_repo) do
    Processor.process(fn -> CodeCorps.GitHub.Sync.sync_repo(github_repo) end)
  end

  @spec track(User.t, GithubRepo.t) :: any
  defp track(%User{id: user_id}, %GithubRepo{project_id: nil} = github_repo) do
    user_id |> SegmentTracker.track("Disconnected GitHub Repo from Project", github_repo)
  end
  defp track(%User{id: user_id}, %GithubRepo{} = github_repo) do
    user_id |> SegmentTracker.track("Connected GitHub Repo to Project", github_repo)
  end
end
