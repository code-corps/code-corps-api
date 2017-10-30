defmodule CodeCorpsWeb.CategoryViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    category = insert(:category)
    project_category = insert(:project_category, category: category)

    category = CodeCorpsWeb.CategoryController.preload(category)
    rendered_json = render(CodeCorpsWeb.CategoryView, "show.json-api", %{ data: category, conn: nil, params: category.id })

    expected_json = %{
      "data" => %{
        "attributes" => %{
          "description" => category.description,
          "name" => category.name,
          "slug" => category.slug
        },
        "id" => category.id |> Integer.to_string,
        "relationships" => %{
          "project-categories" => %{
            "data" => [
              %{"id" => project_category.id |> Integer.to_string, "type" => "project-category"}
            ]
          }
        },
        "type" => "category",
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
