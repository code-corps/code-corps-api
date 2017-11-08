defmodule CodeCorpsWeb.GithubEventControllerTest do
  @moduledoc false

  use CodeCorpsWeb.ApiCase, resource_name: :github_event
  use CodeCorps.BackgroundProcessingCase

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
    test "lists all entries on index", %{conn: conn} do
      [github_event_1, github_event_2] = insert_pair(:github_event)

      conn
        |> request_index
        |> json_response(200)
        |> assert_ids_from_response([github_event_1.id, github_event_2.id])
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

      wait_for_supervisor()

      assert Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end

    @tag :github_webhook
    test "responds with 202 for an unsupported event", %{conn: conn} do
      path = conn |> github_events_path(:create)
      assert conn |> for_event("gollum", "foo") |> post(path, %{}) |> response(202)

      wait_for_supervisor()

      refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end

    @tag :github_webhook
    test "responds with 202 for an unknown event", %{conn: conn} do
      path = conn |> github_events_path(:create)
      assert conn |> for_event("unknown", "foo") |> post(path, %{}) |> response(202)

      wait_for_supervisor()

      refute Repo.get_by(GithubEvent, github_delivery_id: "foo")
    end
  end
end
