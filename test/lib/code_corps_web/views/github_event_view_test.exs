defmodule CodeCorpsWeb.GithubEventViewTest do
  use CodeCorpsWeb.ViewCase

  test "renders all attributes and relationships properly" do
    github_event = insert(:github_event, action: "created", github_delivery_id: "6c305920-c374-11e7-91e8-12f64fc6d596", payload: %{"key" => "value"}, status: "processed", type: "issue_comment")

    rendered_json =
      CodeCorpsWeb.GithubEventView
      |> render("show.json-api", data: github_event)

    expected_json = %{
      "data" => %{
        "id" => github_event.id |> Integer.to_string,
        "type" => "github-event",
        "attributes" => %{
          "action" => github_event.action,
          "data" => github_event.data,
          "event-type" => github_event.type,
          "error" => github_event.error,
          "failure-reason" => github_event.failure_reason,
          "github-delivery-id" => github_event.github_delivery_id,
          "inserted-at" => github_event.inserted_at,
          "payload" => github_event.payload,
          "status" => github_event.status,
          "updated-at" => github_event.updated_at
        }
      },
      "jsonapi" => %{
        "version" => "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
