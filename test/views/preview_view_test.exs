defmodule CodeCorps.PreviewViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  import Phoenix.View

  test "renders all attributes and relationships properly" do
    user = insert(:user)
    preview = insert(:preview, user: user)

    preview = CodeCorps.Preview
    |> Repo.get(preview.id)
    |> Repo.preload([:user])

    rendered_json = render(CodeCorps.PreviewView, "show.json-api", data: preview)

    expected_json = %{
      data: %{
        id: preview.id |> Integer.to_string,
        type: "preview",
        attributes: %{
          "body" => preview.body,
          "inserted-at" => preview.inserted_at,
          "markdown" => preview.markdown,
          "updated-at" => preview.updated_at
        },
        relationships: %{
          "user" => %{
            data: %{
              id: preview.user_id |> Integer.to_string,
              type: "user"
            }
          }
        }
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert expected_json == rendered_json
  end
end
