defmodule CodeCorpsWeb.ConversationViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    conversation = insert(:conversation)

    rendered_json =
      render(CodeCorpsWeb.ConversationView, "show.json-api", data: conversation)

    expected_json = %{
      "data" => %{
        "id" => conversation.id |> Integer.to_string,
        "type" => "conversation",
        "attributes" => %{
          "read-at" => conversation.read_at,
          "status" => conversation.status,
          "inserted-at" => conversation.inserted_at,
          "updated-at" => conversation.updated_at
        },
        "relationships" => %{
          "user" => %{
            "data" => %{
              "id" => conversation.user_id |> Integer.to_string,
              "type" => "user"
            }
          },
          "message" => %{
            "data" => %{
              "id" => conversation.message_id |> Integer.to_string,
              "type" => "message"
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
