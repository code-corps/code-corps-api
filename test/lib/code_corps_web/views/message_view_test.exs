defmodule CodeCorpsWeb.MessageViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    project = insert(:project)
    user = insert(:user)
    message = insert(:message, author: user, project: project)

    rendered_json = render(CodeCorpsWeb.MessageView, "show.json-api", data: message)

    expected_json = %{
      "data" => %{
        "id" => message.id |> Integer.to_string,
        "type" => "message",
        "attributes" => %{
          "body" => message.body,
          "initiated-by" => message.initiated_by,
          "inserted-at" => message.inserted_at,
          "subject" => message.subject,
          "updated-at" => message.updated_at
        },
        "relationships" => %{
          "author" => %{
            "data" => %{"id" => message.author_id |> Integer.to_string, "type" => "user"}
          },
          "project" => %{
            "data" => %{"id" => message.project_id |> Integer.to_string, "type" => "project"}
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
