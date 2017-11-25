defmodule CodeCorps.Services.MarkdownRendererService do
  @moduledoc """
  Used to render provided markdown into html using an external renderer package.
  """

  alias Ecto.Changeset

  @spec render_markdown_to_html(Changeset.t(), atom, atom) :: Changeset.t()
  def render_markdown_to_html(%Changeset{valid?: false} = changeset, _, _), do: changeset
  def render_markdown_to_html(changeset, source_field, destination_field) do
    change = changeset |> Changeset.get_change(source_field)
    changeset |> handle_change(change, destination_field)
  end

  @spec handle_change(Changeset.t(), String.t() | nil, atom) :: Changeset.t()
  defp handle_change(changeset, nil, _), do: changeset
  defp handle_change(changeset, "", destination_field) do
    Changeset.put_change(changeset, destination_field, nil)
  end
  defp handle_change(changeset, lines, destination_field) when is_binary(lines) do
    lines
    |> convert_into_html()
    |> put_into(changeset, destination_field)
  end

  # Prism.js requires a `language-` prefix in code classes
  # See: https://github.com/pragdave/earmark#syntax-highlightning
  @spec convert_into_html(String.t()) :: String.t()
  defp convert_into_html(lines) do
    lines
    |> Earmark.as_html!(%Earmark.Options{code_class_prefix: "language-"})
  end

  @spec put_into(String.t(), Changeset.t(), atom) :: Changeset.t()
  defp put_into(html, changeset, destination_field) do
    changeset |> Changeset.put_change(destination_field, html)
  end
end
