defmodule CodeCorps.ProjectCategoryViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    project_category = insert(:project_category)

    project_category = CodeCorps.ProjectCategory
    |> Repo.get(project_category.id)
    |> Repo.preload([:project, :category])

    rendered_json = render(CodeCorps.ProjectCategoryView, "show.json-api", data: project_category)

    expected_json = %{
      data: %{
        id: project_category.id |> Integer.to_string,
        type: "project-category",
        attributes: %{},
        relationships: %{
          "category" => %{
            data: %{id: project_category.category_id |> Integer.to_string, type: "category"}
          },
          "project" => %{
            data: %{id: project_category.project_id |> Integer.to_string, type: "project"}
          }
        }
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
