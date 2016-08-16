defmodule CodeCorps.MarkdownRendererTest do
  use ExUnit.Case, async: true

  alias CodeCorps.Post

  import CodeCorps.MarkdownRenderer

  test "renders markdown to html" do
    changeset =
      %Post{}
      |> Post.changeset
      |> Ecto.Changeset.put_change(:markdown, "A **strong** body")
      |> render_markdown_to_html(:markdown, :body)

    assert changeset |> Ecto.Changeset.get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
  end
end
