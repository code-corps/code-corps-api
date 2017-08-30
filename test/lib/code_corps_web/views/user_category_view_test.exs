defmodule CodeCorpsWeb.UserCategoryViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    user_category = insert(:user_category)

    rendered_json = render(CodeCorpsWeb.UserCategoryView, "show.json-api", data: user_category)

    expected_json = %{
      "data" => %{
        "id" => user_category.id |> Integer.to_string,
        "type" => "user-category",
        "attributes" => %{},
        "relationships" => %{
          "category" => %{
            "data" => %{"id" => user_category.category_id |> Integer.to_string, "type" => "category"}
          },
          "user" => %{
            "data" => %{"id" => user_category.user_id |> Integer.to_string, "type" => "user"}
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
