defmodule CodeCorpsWeb.GitHubEventsControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ConnCase
  use CodeCorps.{
    BackgroundProcessingCase,
    GitHubCase
  }

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GithubEvent

  setup do
    conn =
      %{build_conn() | host: "api."}
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  defp for_event(conn, type, id) do
    conn
    |> put_req_header("x-github-event", type)
    |> put_req_header("x-github-delivery", id)
  end

  @access_token "v1.1f699f1069f60xxx"
  @expires_at Timex.now() |> Timex.shift(hours: 1) |> DateTime.to_iso8601()
  @access_token_create_response %{"token" => @access_token, "expires_at" => @expires_at}

  @installation_created load_event_fixture("installation_created")
  @installation_repositories load_endpoint_fixture("installation_repositories")

  @tag bypass: %{
    "/installation/repositories" => {200, @installation_repositories},
    "/installations/#{@installation_created["installation"]["id"]}/access_tokens" => {200, @access_token_create_response}
  }
  test "responds with 200 for a supported event", %{conn: conn} do
    path = conn |> github_events_path(:create)

    payload = load_event_fixture("installation_created")
    assert conn |> for_event("installation", "foo") |> post(path, payload) |> response(200)

    wait_for_supervisor()

    assert Repo.get_by(GithubEvent, github_delivery_id: "foo")
  end

  test "responds with 202 for an unsupported event", %{conn: conn} do
    path = conn |> github_events_path(:create)
    assert conn |> for_event("gollum", "foo") |> post(path, %{}) |> response(202)

    wait_for_supervisor()

    refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
  end

  test "responds with 202 for an unknown event", %{conn: conn} do
    path = conn |> github_events_path(:create)
    assert conn |> for_event("unknown", "foo") |> post(path, %{}) |> response(202)

    wait_for_supervisor()

    refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
  end
end
