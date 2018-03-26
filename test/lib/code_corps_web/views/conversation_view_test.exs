defmodule CodeCorpsWeb.ConversationViewTest do
  use CodeCorpsWeb.ViewCase

  alias CodeCorps.Repo

  test "renders index attributes and relationships properly" do
    conversation = insert(:conversation)

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
          "inserted-at" => conversation.inserted_at,
          "read-at" => conversation.read_at,
          "status" => conversation.status,
          "updated-at" => conversation.updated_at
        },
        "relationships" => %{
          "conversation-parts" => %{},
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

  test "renders show attributes and relationships properly" do
    conversation = insert(:conversation)
    conversation_part = insert(:conversation_part, conversation: conversation)

    rendered_json =
      CodeCorpsWeb.ConversationView
      |> render(
        "show.json-api",
        data: conversation |> Repo.preload(:conversation_parts),
        opts: [include: "conversation_parts"]
      )

    expected_json = %{
      "data" => %{
        "id" => conversation.id |> Integer.to_string,
        "type" => "conversation",
        "attributes" => %{
          "inserted-at" => conversation.inserted_at,
          "read-at" => conversation.read_at,
          "status" => conversation.status,
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
      },
      "included" => [
        %{
          "attributes" => %{
            "body" => conversation_part.body, 
            "inserted-at" => conversation_part.inserted_at, 
            "read-at" => conversation_part.read_at, 
            "updated-at" => conversation_part.updated_at
          },
          "relationships" => %{
            "author" => %{
              "data" => %{
                "id" => conversation_part.author.id |> Integer.to_string,
                "type" => "user"
              }
            }
          },
          "id" => conversation_part.id |> Integer.to_string, 
          "type" => "conversation-part"
        }
      ]
    }

    assert rendered_json == expected_json
  end
end
