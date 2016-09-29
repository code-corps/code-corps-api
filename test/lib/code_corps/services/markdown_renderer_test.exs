defmodule CodeCorps.MarkdownRendererTest do
  use ExUnit.Case, async: true

  alias CodeCorps.Task

  import CodeCorps.MarkdownRenderer

  @valid_attrs %{
    title: "Test task",
    task_type: "issue",
    markdown: "A **strong** body",
    status: "open"
  }

  test "renders markdown to html" do
    changeset =
      %Task{}
      |> Task.changeset(@valid_attrs)
      |> render_markdown_to_html(:markdown, :body)

    assert changeset |> Ecto.Changeset.get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
  end

  test "returns changeset when changeset is invalid" do
    changeset =
      %Task{}
      |> Task.changeset
      |> Ecto.Changeset.put_change(:markdown, "")
      |> render_markdown_to_html(:markdown, :body)

    refute changeset.valid?
    assert changeset |> Ecto.Changeset.get_change(:body) == nil
  end
end
