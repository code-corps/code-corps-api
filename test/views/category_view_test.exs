defmodule CodeCorps.CategoryViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    project_category = insert(:project_category)

    category =
      CodeCorps.Category
      |> Repo.get(project_category.category_id)
      |> CodeCorps.Repo.preload([:project_categories])

    rendered_json =  render(CodeCorps.CategoryView, "show.json-api", data: category)

    expected_json = %{
      data: %{
        attributes: %{
          "description" => category.description,
          "name" => category.name,
          "slug" => category.slug
        },
        id: category.id |> Integer.to_string,
        relationships: %{
          "project-categories" => %{
            data: [
              %{id: project_category.id |> Integer.to_string, type: "project-category"}
            ]
          }
        },
        type: "category",
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
