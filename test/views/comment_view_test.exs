defmodule CodeCorps.CommentViewTest do
  use CodeCorps.ConnCase, async: true

  alias CodeCorps.Repo

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders all attributes and relationships properly" do
    user = insert(:user)
    post = insert(:post)
    comment = insert(:comment, user: user, post: post)

    comment = CodeCorps.Comment
    |> Repo.get(comment.id)
    |> Repo.preload([:user, :post])

    rendered_json = render(CodeCorps.CommentView, "show.json-api", data: comment)

    expected_json = %{
      data: %{
        id: comment.id |> Integer.to_string,
        type: "comment",
        attributes: %{
          "inserted-at" => comment.inserted_at,
          "body" => comment.body,
          "markdown" => comment.markdown,
          "updated-at" => comment.updated_at
        },
        relationships: %{
          "user" => %{
            data: %{id: comment.user_id |> Integer.to_string,
                    type: "user"}
          },
          "post" => %{
            data: %{id:comment.post_id |> Integer.to_string,
                    type: "post"}
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
