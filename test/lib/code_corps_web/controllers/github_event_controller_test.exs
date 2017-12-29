defmodule CodeCorpsWeb.GithubEventControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :github_event

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GithubEvent

  defp for_event(conn, type, id) do
    conn
    |> put_req_header("x-github-event", type)
    |> put_req_header("x-github-delivery", id)
  end

  describe "index" do
    @tag authenticated: :admin
    test "paginates on index", %{conn: conn} do
      [_github_event_1, github_event_2] = insert_pair(:github_event)

      path = "github-events/?page[page]=2&page[page-size]=1"

      conn
        |> get(path)
        |> json_response(200)
        |> assert_ids_from_response([github_event_2.id])
    end

    @tag authenticated: :admin
    test "lists all entries on index by inserted_at desc", %{conn: conn} do
      past_event = insert(:github_event, inserted_at: Timex.now())
      recent_event = insert(:github_event, inserted_at: Timex.now() |> Timex.shift(days: 3))

      data =
        conn
        |> request_index
        |> json_response(200)
        |> Map.get("data")

      [first_event, second_event] = data
      assert first_event["id"] == recent_event.id |> Integer.to_string
      assert second_event["id"] == past_event.id |> Integer.to_string
    end

    @tag authenticated: :admin
    test "filters resources on index", %{conn: conn} do
      [github_event_1, github_event_2 | _] = insert_list(3, :github_event)

      path = "github-events/?filter[id]=#{github_event_1.id},#{github_event_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([github_event_1.id, github_event_2.id])
    end

    @tag authenticated: :admin
    test "filters resources on index with query params", %{conn: conn} do
      expected_event = insert(:github_event, action: "opened", status: "processed", type: "issues")
      insert(:github_event, action: "created")
      insert(:github_event, status: "unprocessed")
      insert(:github_event, type: "installation")

      path = "github-events/?action=opened&status=processed&type=issues"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([expected_event.id])
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_index() |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      assert conn |> request_index() |> json_response(403)
    end
  end

  describe "show" do
    @tag authenticated: :admin
    test "shows chosen resource", %{conn: conn} do
      github_event = insert(:github_event)

      conn
      |> request_show(github_event)
      |> json_response(200)
      |> assert_id_from_response(github_event.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      github_event = insert(:github_event)
      assert conn |> request_show(github_event) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      github_event = insert(:github_event)
      assert conn |> request_show(github_event) |> json_response(403)
    end
  end

  describe "create" do
    @tag :github_webhook
    test "responds with 200 for a supported event", %{conn: conn} do
      path = conn |> github_events_path(:create)
      payload = load_event_fixture("installation_created")
      assert conn |> for_event("installation", "foo") |> post(path, payload) |> response(200)

      assert Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end

    @tag :github_webhook
    test "responds with 200 for an unsupported event", %{conn: conn} do
      path = conn |> github_events_path(:create)
      payload = load_event_fixture("pull_request_synchronize")
      insert(:github_repo, github_id: payload["repository"]["id"])
      assert conn |> for_event("pull_request", "foo") |> post(path, payload) |> response(200)

      assert Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end

    @tag :github_webhook
    test "responds with 202 for a supported event but no project_id", %{conn: conn} do
      path = conn |> github_events_path(:create)
      payload = load_event_fixture("pull_request_synchronize")
      insert(:github_repo, github_id: payload["repository"]["id"], project: nil)
      assert conn |> for_event("pull_request", "foo") |> post(path, payload) |> response(202)

      refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end

    @tag :github_webhook
    test "responds with 202 for an unknown event", %{conn: conn} do
      path = conn |> github_events_path(:create)
      assert conn |> for_event("unknown", "foo") |> post(path, %{}) |> response(202)

      refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end
  end

  describe "update" do
    @valid_attrs %{retry: true}

    @tag authenticated: :admin
    test "updates when the status was errored", %{conn: conn} do
      payload = load_event_fixture("pull_request_opened")
      github_event = insert(:github_event, action: "opened", github_delivery_id: "foo", payload: payload, status: "errored", type: "pull_request")

      assert conn |> request_update(github_event, @valid_attrs) |> json_response(200)
    end

    @tag authenticated: :admin
    test "does not update for any other status", %{conn: conn} do
      payload = load_event_fixture("pull_request_opened")
      github_event = insert(:github_event, action: "opened", payload: payload, status: "processed", type: "pull_request")

      assert conn |> request_update(github_event, @valid_attrs) |> json_response(422)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end
  end
end
