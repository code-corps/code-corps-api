defmodule CodeCorps.ProjectCategoryControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Category
  alias CodeCorps.Project
  alias CodeCorps.ProjectCategory
  alias CodeCorps.Repo

  @attrs %{}

  defp build_payload, do: %{ "data" => %{"type" => "project-category", "attributes" => %{}}}
  defp put_relationships(payload, project, category) do
    relationships = build_relationships(project, category)
    payload |> put_in(["data", "relationships"], relationships)
  end

  defp build_relationships(project, category) do
    %{
      project: %{data: %{id: project.id}},
      category: %{data: %{id: category.id}}
    }
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, project_category_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "filters resources on index", %{conn: conn} do
      arts = insert(:category, name: "Arts")
      society = insert(:category, name: "Society")
      technology = insert(:category, name: "Technology")

      project = insert(:project)
      project_category_1 = insert(:project_category, project: project, category: arts)
      project_category_2 = insert(:project_category, project: project, category: society)
      insert(:project_category, project: project, category: technology)

      json =
        conn
        |> get("project-categories/?filter[id]=#{project_category_1.id},#{project_category_2.id}")
        |> json_response(200)
      data = json["data"]
      assert length(data) == 2
      [first_result, second_result | _] = data

      assert first_result["id"] == "#{project_category_1.id}"
      assert first_result["relationships"]["project"]["data"]["id"] == "#{project.id}"
      assert first_result["relationships"]["project"]["data"]["type"] == "project"
      assert first_result["relationships"]["category"]["data"]["id"] == "#{arts.id}"
      assert first_result["relationships"]["category"]["data"]["type"] == "category"

      assert second_result["id"] == "#{project_category_2.id}"
      assert second_result["relationships"]["project"]["data"]["id"] == "#{project.id}"
      assert second_result["relationships"]["project"]["data"]["type"] == "project"
      assert second_result["relationships"]["category"]["data"]["id"] == "#{society.id}"
      assert second_result["relationships"]["category"]["data"]["type"] == "category"
    end
  end

  describe "show" do
    test "shows chosen resource", %{conn: conn} do
      category = insert(:category)
      project = insert(:project)
      project_category = insert(:project_category, project: project, category: category)
      conn = get conn, project_category_path(conn, :show, project_category)
      data = json_response(conn, 200)["data"]
      assert data["id"] == "#{project_category.id}"
      assert data["type"] == "project-category"
      assert data["attributes"] == %{}
      assert data["relationships"]["project"]["data"]["id"] == "#{project.id}"
      assert data["relationships"]["project"]["data"]["type"] == "project"
      assert data["relationships"]["category"]["data"]["id"] == "#{category.id}"
      assert data["relationships"]["category"]["data"]["type"] == "category"
    end

    test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
      path = conn |> project_category_path(:show, -1)
      assert conn |> get(path) |> json_response(:not_found)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      category = insert(:category)
      project = insert(:project, organization: organization)
      insert(:organization_membership, role: "admin", member: current_user, organization: organization)


      payload = build_payload |> put_relationships(project, category)

      path = conn |> project_category_path(:create)
      data = conn |> post(path, payload) |> json_response(201) |> Map.get("data")

      id = data["id"]
      assert data["relationships"]["project"]["data"]["id"] |> String.to_integer == project.id
      assert data["relationships"]["category"]["data"]["id"] |> String.to_integer == category.id

      project_category = ProjectCategory |> Repo.get(id)
      assert project_category
      assert project_category.project_id == project.id
      assert project_category.category_id == category.id
    end

    @tag authenticated: :admin
    test "does not create resource and renders 422 when data is invalid", %{conn: conn} do
      payload = build_payload()

      path = conn |> project_category_path(:create)
      data = conn |> post(path, payload) |> json_response(422)
      assert data["errors"] != %{}
    end

    test "does not create resource and renders 401 when unauthenticated", %{conn: conn} do
      payload = build_payload()

      path = conn |> project_category_path(:create)
      assert conn |> post(path, payload) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn, current_user: current_user} do
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      category = insert(:category)
      insert(:organization_membership, role: "contributor", member: current_user, organization: organization)

      payload = build_payload |> put_relationships(project, category)

      path = conn |> project_category_path(:create)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end

  describe "delete" do
    @tag authenticated: :admin
    test "deletes resource", %{conn: conn} do
      project_category = insert(:project_category)

      path = conn |> project_category_path(:delete, project_category)

      assert conn |> delete(path) |> response(204)

      refute Repo.get(ProjectCategory, project_category.id)
      assert Repo.get(Project, project_category.project_id)
      assert Repo.get(Category, project_category.category_id)
    end

    test "does not delete resource and renders 401 when unauthenticated", %{conn: conn} do
      project_category = insert(:project_category)
      path = conn |> project_category_path(:delete, project_category)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      project_category = insert(:project_category)
      path = conn |> project_category_path(:delete, project_category)
      assert conn |> delete(path) |> json_response(401)
    end

    @tag :authenticated
    test "renders page not found when id is nonexistent on delete", %{conn: conn} do
      path = conn |> project_category_path(:delete, -1)
      assert conn |> delete(path) |> json_response(404)
    end
  end
end
