defmodule CodeCorpsWeb.ChangesetView do
  @moduledoc false
  use CodeCorpsWeb, :view
  use JaSerializer.PhoenixView

  import CodeCorpsWeb.Gettext

  alias Ecto.Changeset
  alias JaSerializer.Formatter.Utils

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `CodeCorpsWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(%Ecto.Changeset{} = changeset) do
    errors =
      changeset
      |> Changeset.traverse_errors(&translate_error/1)
      |> format_errors()
    errors
  end

  defp format_errors(errors) do
    errors
    |> Map.keys
    |> Enum.map(fn(attribute) -> format_attribute_errors(errors, attribute) end)
    |> Enum.flat_map(fn(error) -> error end)
  end

  defp format_attribute_errors(errors, attribute) do
    errors
    |> Map.get(attribute)
    |> Enum.map(&create_error(attribute, &1))
  end

  def create_error(attribute, message) do
    %{
      detail: format_detail(attribute, message),
      title: message,
      source: %{
        pointer: "data/attributes/#{Utils.format_key(attribute)}"
      },
      status: "422"
    }
  end

  def render("422.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{
      errors: translate_errors(changeset),
      jsonapi: %{
        version: "1.0"
      }
    }
  end

  defp format_detail(attribute, message) do
    "#{attribute |> Utils.humanize |> translate_attribute} #{message}"
  end

  defp translate_attribute("Cloudinary public"), do: dgettext("errors", "Cloudinary public")
  defp translate_attribute("Github"), do: dgettext("errors", "Github")
  defp translate_attribute("Slug"), do: dgettext("errors", "Slug")
  defp translate_attribute(attribute), do: attribute
end
