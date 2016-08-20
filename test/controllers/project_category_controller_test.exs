defmodule CodeCorps.ProjectCategoryControllerTest do
  use CodeCorps.ConnCase

  import CodeCorps.Factories

  alias CodeCorps.Category
  alias CodeCorps.Project
  alias CodeCorps.ProjectCategory
  alias CodeCorps.Repo

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  @attributes %{}

  defp build_relationships(nil, nil), do: %{}
  defp build_relationships(project, category) do
    %{
      project: %{data: %{id: project.id}},
      category: %{data: %{id: category.id}}
    }
  end

  defp build_payload(), do: build_payload(nil, nil)
  defp build_payload(project, category) do
    relationships = build_relationships(project, category)
    %{
      "meta" => %{},
      "data" => %{
        "type" => "project-category",
        "attributes" => %{},
        "relationships" => relationships
      }
    }
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    category = insert(:category)
    project = insert(:project)

    payload = build_payload(project, category)

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

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    payload = build_payload()

    path = conn |> project_category_path(:create)
    data = conn |> post(path, payload) |> json_response(422)
    assert data["errors"] != %{}
  end

  test "deletes resource", %{conn: conn} do
    project_category = insert(:project_category)

    path = conn |> project_category_path(:delete, project_category)

    assert conn |> delete(path) |> response(204)

    refute Repo.get(ProjectCategory, project_category.id)
    assert Repo.get(Project, project_category.project_id)
    assert Repo.get(Category, project_category.category_id)
  end

  test "renders page not found when id is nonexistent on delete", %{conn: conn} do
    assert_error_sent 404, fn ->
      delete conn, project_category_path(conn, :delete, -1)
    end
  end
end
