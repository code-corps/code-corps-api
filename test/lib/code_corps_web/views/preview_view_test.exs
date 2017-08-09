defmodule CodeCorpsWeb.PreviewViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    user = insert(:user)
    preview = insert(:preview, user: user)

    rendered_json = render(CodeCorpsWeb.PreviewView, "show.json-api", data: preview)

    expected_json = %{
      "data" => %{
        "id" => preview.id |> Integer.to_string,
        "type" => "preview",
        "attributes" => %{
          "body" => preview.body,
          "inserted-at" => preview.inserted_at,
          "markdown" => preview.markdown,
          "updated-at" => preview.updated_at
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "id" => preview.user_id |> Integer.to_string,
              "type" => "user"
            }
          }
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert expected_json == rendered_json
  end
end
