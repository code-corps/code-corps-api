defmodule CodeCorps.ModelHelpers do
  import Ecto.Changeset

  def generate_slug(changeset, value_key, slug_key) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, value} = Map.fetch(changes, value_key)
        put_change(changeset, slug_key, Inflex.parameterize(value))
      _ ->
        changeset
    end
  end
end
