defmodule CodeCorpsWeb.ConversationPartViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    conversation_part = insert(:conversation_part)

    rendered_json =
      render(CodeCorpsWeb.ConversationPartView, "show.json-api", data: conversation_part)

    expected_json = %{
      "data" => %{
        "id" => conversation_part.id |> Integer.to_string,
        "type" => "conversation-part",
        "attributes" => %{
          "body" => conversation_part.body,
          "inserted-at" => conversation_part.inserted_at,
          "read-at" => conversation_part.read_at,
          "updated-at" => conversation_part.updated_at
        },
        "relationships" => %{
          "author" => %{
            "data" => %{
              "id" => conversation_part.author_id |> Integer.to_string,
              "type" => "user"
            }
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
