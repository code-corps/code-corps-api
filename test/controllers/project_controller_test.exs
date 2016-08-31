defmodule CodeCorps.ProjectControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Project

  @valid_attrs %{
    title: "Valid project",
    description: "Valid project description",
    long_description_markdown: "Valid **markdown**"
  }

  @invalid_attrs %{
    title: ""
  }

  defp build_payload, do: %{ "data" => %{"type" => "project"}}
  defp put_id(payload, id), do: payload |> put_in(["data", "id"], id)
  defp put_attributes(payload, attributes), do: payload |> put_in(["data", "attributes"], attributes)
  defp put_relationships(payload, organization) do
    relationships = build_relationships(organization)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(organization) do
    %{
      organization: %{data: %{id: organization.id}}
    }
  end

  describe "#index" do
    test "lists all entries on index", %{conn: conn} do
      path = conn |> project_path(:index)
      json = conn |> get(path) |> json_response(200)

      assert json["data"] == []
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
  end

  describe "#show" do
    test "shows chosen resource", %{conn: conn} do
      project = insert(:project,
        title: "Test project",
        description: "Test project description",
        long_description_markdown: "A markdown **description**")

      conn = get conn, project_path(conn, :show, project)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{project.id}"
      assert data["type"] == "project"
      assert data["attributes"]["title"] == "Test project"
      assert data["attributes"]["description"] == "Test project description"
      assert data["attributes"]["long-description-markdown"] == "A markdown **description**"
      assert data["relationships"]["organization"]["data"]["id"] == Integer.to_string(project.organization_id)
      assert data["relationships"]["project-categories"]["data"] == []
      assert data["relationships"]["project-skills"]["data"] == []
      assert data["relationships"]["skills"]["data"] == []
    end

    test "shows chosen resource retrieved by slug", %{conn: conn} do
      project = insert(:project,
        title: "Test project",
        description: "Test project description",
        long_description_markdown: "A markdown **description**",
        slug: "test-project")

      conn = get conn, "/test-organization/test-project"

      data =
        conn
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] == "#{project.id}"
      assert data["type"] == "project"
      assert data["attributes"]["title"] == "Test project"
      assert data["attributes"]["description"] == "Test project description"
      assert data["attributes"]["long-description-markdown"] == "A markdown **description**"
      assert data["relationships"]["organization"]["data"]["id"] == Integer.to_string(project.organization_id)
    end
  end

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when attributes are valid", %{conn: conn} do
      organization = insert(:organization)

      payload =
        build_payload
        |> put_attributes(@valid_attrs)
        |> put_relationships(organization)

      path = conn |> project_path(:create)

      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"]
      assert id
      project = Project |> Repo.get(id)

      assert project
      assert project.title == "Valid project"
      assert project.description == "Valid project description"
      assert project.long_description_markdown == "Valid **markdown**"
      assert project.long_description_body == "<p>Valid <strong>markdown</strong></p>\n"
      assert project.organization_id == organization.id
    end

    @tag authenticated: :admin
    test "does not create resource and renders errors when attributes are invalid", %{conn: conn} do
      payload = build_payload |> put_attributes(@invalid_attrs)
      path = conn |> project_path(:create)
      errors = conn |> post(path, payload) |> json_response(422) |> Map.get("errors")

      assert errors != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> project_path(:create)
      assert conn |> post(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      path = conn |> project_path(:create)
      assert conn |> post(path) |> json_response(401)
    end
  end

  describe "update" do
    @tag authenticated: :admin
    test "updates and renders resource when attributes are valid", %{conn: conn} do
      project = insert(:project)

      payload = build_payload |> put_id(project.id) |> put_attributes(@valid_attrs)
      path = conn |> project_path(:update, project)

      json = conn |> put(path, payload) |> json_response(201)

      id = json["data"]["id"]
      assert id

      project = Project |> Repo.get(id)

      assert project
      assert project.title == "Valid project"
      assert project.description == "Valid project description"
      assert project.long_description_markdown == "Valid **markdown**"
      assert project.long_description_body == "<p>Valid <strong>markdown</strong></p>\n"
      assert project.organization_id
    end

    @tag authenticated: :admin
    test "renders errors when attributes are invalid", %{conn: conn} do
      project = insert(:project)

      payload = build_payload |> put_id(project.id) |> put_attributes(@invalid_attrs)
      path = conn |> project_path(:update, project)

      errors = conn |> put(path, payload) |> json_response(422) |> Map.get("errors")

      assert errors != %{}
    end

    @tag :requires_env
    @tag authenticated: :admin
    test "uploads a icon to S3", %{conn: conn} do
      project = insert(:project)

      icon_data = "data:image/gif;base64,R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs="
      attrs = Map.put(@valid_attrs, :base64_icon_data, icon_data)

      payload = build_payload |> put_id(project.id) |> put_attributes(attrs)
      path = conn |> project_path(:update, project)

      json = conn |> put(path, payload) |> json_response(201)

      data = json["data"]
      large_url = data["attributes"]["icon-large-url"]
      assert large_url
      assert String.contains? large_url, "/projects/#{project.id}/large"
      thumb_url = data["attributes"]["icon-thumb-url"]
      assert thumb_url
      assert String.contains? thumb_url, "/projects/#{project.id}/thumb"
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      path = conn |> project_path(:update, "id not important")
      assert conn |> put(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      project = insert(:project)
      path = conn |> project_path(:update, project)
      assert conn |> put(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not update resource and renders 404 when not found", %{conn: conn} do
      path = conn |> project_path(:update, -1)
      assert conn |> put(path) |> json_response(404)
    end
  end
end
