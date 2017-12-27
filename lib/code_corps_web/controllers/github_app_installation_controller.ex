defmodule CodeCorpsWeb.GithubAppInstallationController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.{Analytics.SegmentTracker, GithubAppInstallation, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    installations =
      GithubAppInstallation
      |> id_filter(params)
      |> Repo.all()
      |> preload()

    conn |> render("index.json-api", data: installations)
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %GithubAppInstallation{} = installation <- GithubAppInstallation |> Repo.get(id) |> preload() do
      conn |> render("show.json-api", data: installation)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %GithubAppInstallation{}, params),
         {:ok, %GithubAppInstallation{} = installation} <- %GithubAppInstallation{} |> GithubAppInstallation.create_changeset(params) |> Repo.insert,
         installation <- preload(installation)
    do
      current_user |> track_created(installation)
      conn |> put_status(:created) |> render("show.json-api", data: installation)
    end
  end

  @preloads [:github_repos, :organization_github_app_installations]

  def preload(data) do
    Repo.preload(data, @preloads)
  end

  @spec track_created(User.t, GithubAppInstallation.t) :: any
  defp track_created(%User{id: user_id}, %GithubAppInstallation{} = installation) do
    user_id |> SegmentTracker.track("Created GitHub App Installation", installation)
  end
end
