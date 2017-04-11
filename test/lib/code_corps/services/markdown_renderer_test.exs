defmodule CodeCorps.Services.MarkdownRendererServiceTest do
  use ExUnit.Case, async: true

  import CodeCorps.Services.MarkdownRendererService

  alias CodeCorps.Web.Task

  @valid_attrs %{
    title: "Test task",
    task_list_id: 1,
    markdown: "A **strong** body",
    status: "open"
  }

  test "renders empty strings to nil" do
    attrs = @valid_attrs |> Map.merge(%{markdown: ""})
    changeset =
      %Task{}
      |> Task.changeset(attrs)
      |> render_markdown_to_html(:markdown, :body)

    assert changeset |> Ecto.Changeset.get_change(:body) == nil
  end

  test "returns unchanged changeset when nil" do
    attrs = @valid_attrs |> Map.merge(%{markdown: nil})
    changeset =
      %Task{}
      |> Task.changeset(attrs)
      |> render_markdown_to_html(:markdown, :body)

    assert changeset == %Task{} |> Task.changeset(attrs)
  end

  test "renders markdown to html" do
    changeset =
      %Task{}
      |> Task.changeset(@valid_attrs)
      |> render_markdown_to_html(:markdown, :body)

    assert changeset |> Ecto.Changeset.get_change(:body) == "<p>A <strong>strong</strong> body</p>\n"
  end

  test "adds the right css class prefixes" do
    attrs = @valid_attrs |> Map.merge(%{markdown: "```css\nspan {}\n```"})
    changeset =
      %Task{}
      |> Task.changeset(attrs)
      |> render_markdown_to_html(:markdown, :body)

    assert changeset |> Ecto.Changeset.get_change(:body) == "<pre><code class=\"css language-css\">span {}</code></pre>\n"
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
