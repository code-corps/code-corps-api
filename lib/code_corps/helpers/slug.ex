defmodule CodeCorps.Helpers.Slug do
  alias Ecto.Changeset

  def generate_slug(changeset, value_key, slug_key) do
    case changeset do
      %Changeset{valid?: true, changes: changes} ->
        case Map.fetch(changes, value_key) do
          {:ok, value} -> Changeset.put_change(changeset, slug_key, Inflex.parameterize(value))
          _ -> changeset
        end
      _ ->
        changeset
    end
  end
end
