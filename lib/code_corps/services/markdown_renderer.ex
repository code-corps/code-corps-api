defmodule CodeCorps.Services.MarkdownRendererService do
  def render_markdown_to_html(changeset, source_field, destination_field) do
    case changeset do
      %Ecto.Changeset{valid?: false} ->
        changeset
      %Ecto.Changeset{changes: %{^source_field => _}} ->
        changeset
        |> do_render_markdown_to_html(source_field, destination_field)
      _ ->
        changeset
    end
  end
  defp do_render_markdown_to_html(changeset, source_field, destination_field) do
    markdown =
      changeset
      |> Ecto.Changeset.get_change(source_field)

    {html, _errors} =
      markdown
      |> Earmark.as_html()

    changeset
    |> Ecto.Changeset.put_change(destination_field, html)
  end
end
