defmodule CodeCorpsWeb.GithubIssueController do
  use CodeCorpsWeb, :controller

  alias CodeCorps.{GithubIssue, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with github_repos <- GithubIssue |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: github_repos)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %GithubIssue{} = github_repo <- GithubIssue |> Repo.get(id) do
      conn |> render("show.json-api", data: github_repo)
    end
  end
end
