defmodule CodeCorps.GithubAppInstallationControllerTest do
  @moduledoc false

  use CodeCorps.ApiCase, resource_name: :github_app_installation

  describe "index" do
    test "lists all resources", %{conn: conn} do
      [record_1, record_2] = insert_pair(:github_app_installation)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end

    test "filters resources by record id", %{conn: conn} do
      [record_1, record_2 | _] = insert_list(3, :github_app_installation)

      path = "github-app-installations/?filter[id]=#{record_1.id},#{record_2.id}"

      conn
      |> get(path)
      |> json_response(200)
      |> assert_ids_from_response([record_1.id, record_2.id])
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      record = insert(:github_app_installation)
      conn
      |> request_show(record)
      |> json_response(200)
      |> assert_id_from_response(record.id)
    end

    test "renders 404 when id is nonexistent", %{conn: conn} do
      assert conn |> request_show(:not_found) |> json_response(404)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: user} do
      project = insert(:project)
      insert(:project_user, project: project, user: user, role: "owner")
      attrs = %{project: project, user: user}

      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{conn: conn, current_user: user} do
      project = insert(:project)
      insert(:project_user, project: project, user: user, role: "owner")
      attrs = %{project: project, user: nil}
      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end
  end
end
