defmodule CodeCorpsWeb.ConversationViewTest do
  use CodeCorpsWeb.ViewCase

  alias CodeCorps.Repo

  test "renders all attributes and relationships properly" do
    conversation = insert(:conversation)
    conversation_part = insert(:conversation_part, conversation: conversation)

    rendered_json =
      CodeCorpsWeb.ConversationView
      |> render(
        "show.json-api",
        data: conversation |> Repo.preload(:conversation_parts)
      )

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
          "conversation-parts" => %{
            "data" => [
              %{
                "id" => conversation_part.id |> Integer.to_string,
                "type" => "conversation-part"
              }
            ]
          },
          "message" => %{
            "data" => %{
              "id" => conversation.message_id |> Integer.to_string,
              "type" => "message"
            }
          },
          "user" => %{
            "data" => %{
              "id" => conversation.user_id |> Integer.to_string,
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
