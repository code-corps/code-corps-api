defmodule CodeCorps.ProjectControllerTest do
  use CodeCorps.ApiCase, resource_name: :project

  @valid_attrs %{title: "Valid project"}
  @invalid_attrs %{title: ""}

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      [project_1, project_2] = insert_pair(:project)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([project_1.id, project_2.id])
    end

    test "lists all entries for organization specified by slug", %{conn: conn} do
      organization_slug = "test-organization"
      organization = insert(:organization, name: "Test Organization", slug: organization_slug)
      insert(:slugged_route, organization: organization, slug: organization_slug)
      project_1 = insert(:project, title: "Test Project 1", organization: organization)
      project_2 = insert(:project, title: "Test Project 2", organization: organization)

      conn = conn |> get("/#{organization_slug}/projects")

      data = conn |> json_response(200) |> Map.get("data")

      assert Enum.count(data) == 2

      actual_ids =
        data
        |> Enum.map(& &1["id"])
        |> Enum.map(&Integer.parse(&1) |> elem(0))
        |> Enum.sort

      expected_ids =
        [project_1, project_2]
        |> Enum.map(& &1.id)
        |> Enum.sort

      assert expected_ids == actual_ids
    end

    test "listing by organization slug is case insensitive", %{conn: conn} do
      organization = insert(:organization)
      insert(:slugged_route, slug: "codecorps", organization: organization)

      assert conn |> get("/codeCorps/projects") |> json_response(200)
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      project = insert(:project)

      conn
      |> request_show(project)
      |> json_response(200)
      |> Map.get("data")
      |> assert_result_id(project.id)
    end

    test "shows chosen resource retrieved by slug", %{conn: conn} do
      project = insert(:project, title: "Test project", slug: "test-project")

      conn = get conn, "/test-organization/test-project"

        conn
        |> json_response(200)
        |> Map.get("data")
        |> assert_result_id(project.id)
    end

    test "retrieval by slug is case insensitive", %{conn: conn} do
      organization = insert(:organization, slug: "codecorps")
      insert(:project, slug: "codecorpsproject", organization: organization)

      assert conn |> get("codeCorps/codeCorpsProject") |> json_response(200)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when attributes are valid", %{conn: conn, current_user: current_user} do
      assert conn |> request_create(@valid_attrs) |> json_response(201)
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when attributes are invalid", %{conn: conn, current_user: current_user} do
      assert conn |> request_create(@invalid_attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn, current_user: current_user} do
      assert conn |> request_create |> json_response(403)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders resource when attributes are valid", %{conn: conn} do
      assert conn |> request_update(@valid_attrs) |> json_response(200)
    end

    @tag authenticated: :admin
    test "renders errors when attributes are invalid", %{conn: conn} do
      assert conn |> request_update(@invalid_attrs) |> json_response(422)
    end

    @tag :requires_env
    @tag authenticated: :admin
    test "uploads a icon to S3", %{conn: conn} do
      project = insert(:project)

      icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      attrs = Map.put(@valid_attrs, :base64_icon_data, icon_data)

      payload = build_payload |> put_id(project.id) |> put_attributes(attrs)
      path = conn |> project_path(:update, project)

      json = conn |> put(path, payload) |> json_response(200)

      data = json["data"]
      large_url = data["attributes"]["icon-large-url"]
      assert large_url
      assert String.contains? large_url, "/projects/#{project.id}/large"
      thumb_url = data["attributes"]["icon-thumb-url"]
      assert thumb_url
      assert String.contains? thumb_url, "/projects/#{project.id}/thumb"
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      assert conn |> request_update |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_update |> json_response(403)
    end

    @tag authenticated: :admin
    test "does not update resource and renders 404 when not found", %{conn: conn} do
      assert conn |> request_update(:not_found) |> json_response(404)
    end
  end
end
