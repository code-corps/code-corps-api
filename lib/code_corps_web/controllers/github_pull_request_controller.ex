defmodule CodeCorpsWeb.GithubPullRequestController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{GithubPullRequest, Helpers.Query}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with github_pull_requests <- GithubPullRequest |> Query.id_filter(params) |> Repo.all do
      conn |> render("index.json-api", data: github_pull_requests)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %GithubPullRequest{} = github_pull_request <- GithubPullRequest |> Repo.get(id) do
      conn |> render("show.json-api", data: github_pull_request)
    end
  end
end
