defmodule CodeCorps.Web.ChangesetView do
  use CodeCorps.Web, :view

  alias Ecto.Changeset

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `CodeCorps.Web.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    errors =
      changeset
      |> Changeset.traverse_errors(&translate_error/1)
      |> format_errors
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
    |> Enum.map(fn(message) -> create_error(attribute, message) end)
  end

  def create_error(attribute, message) do
    %{
      id: "VALIDATION_ERROR",
      source: %{
        pointer: "data/attributes/#{attribute}"
      },
      detail: message,
      status: 422
    }
  end

  def render("error.json-api", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
