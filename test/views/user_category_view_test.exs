defmodule CodeCorps.UserCategoryViewTest do
  use CodeCorps.ConnCase, async: true

  import CodeCorps.Factories

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    db_user_category = insert(:user_category)

    user_category =
      CodeCorps.UserCategory
      |> Repo.get(db_user_category.id)
      |> Repo.preload([:user, :category])

    rendered_json = render(CodeCorps.UserCategoryView, "show.json-api", data: user_category)

    expected_json = %{
      data: %{
        id: user_category.id |> Integer.to_string,
        type: "user-category",
        attributes: %{},
        relationships: %{
          "category" => %{
            data: %{id: user_category.category_id |> Integer.to_string, type: "category"}
          },
          "user" => %{
            data: %{id: user_category.user_id |> Integer.to_string, type: "user"}
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
