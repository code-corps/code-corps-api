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

  describe "create" do
    @tag authenticated: :admin
    test "creates and renders resource when data is valid", %{conn: conn} do
      category = insert(:category)
      project = insert(:project)

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
    test "does not create resource and renders 401 when not authorized", %{conn: conn} do
      payload = build_payload()

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
