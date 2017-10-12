defmodule CodeCorpsWeb.GithubRepoController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{GithubRepo, Helpers.Query}

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
end
