defmodule CodeCorps.PostViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  import Phoenix.View, only: [render: 3]

  test "renders all attributes and relationships properly" do
    post = insert(:post)
    comment = insert(:comment, post: post)

    post =
      CodeCorps.Post
      |> Repo.get(post.id)
      |> CodeCorps.Repo.preload([:comments, :project, :user])

    rendered_json =  render(CodeCorps.PostView, "show.json-api", data: post)

    expected_json = %{
      data: %{
        attributes: %{
          "body" => post.body,
          "inserted-at" => post.inserted_at,
          "markdown" => post.markdown,
          "number" => post.number,
          "post-type" => post.post_type,
          "status" => post.status,
          "state" => post.state,
          "title" => post.title,
          "updated-at" => post.updated_at,
        },
        id: post.id |> Integer.to_string,
        relationships: %{
          "comments" => %{
            data: [
              %{
                id: comment.id |> Integer.to_string,
                type: "comment"
              }
            ]
          },
          "project" => %{
            data: %{
              id: post.project_id |> Integer.to_string,
              type: "project"
            }
          },
          "user" => %{
            data: %{
              id: post.user_id |> Integer.to_string,
              type: "user"
            }
          }
        },
        type: "post",
      },
      jsonapi: %{
        version: "1.0"
      }
    }

    assert rendered_json == expected_json
  end
end
