defmodule CodeCorps.ProjectCategoryViewTest do
  use CodeCorps.ViewCase

  test "renders all attributes and relationships properly" do
    project_category = insert(:project_category)

    rendered_json = render(CodeCorps.ProjectCategoryView, "show.json-api", data: project_category)

    expected_json = %{
      "data" => %{
        "id" => project_category.id |> Integer.to_string,
        "type" => "project-category",
        "attributes" => %{},
        "relationships" => %{
          "category" => %{
            "data" => %{"id" => project_category.category_id |> Integer.to_string, "type" => "category"}
          },
          "project" => %{
            "data" => %{"id" => project_category.project_id |> Integer.to_string, "type" => "project"}
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
