defmodule CodeCorps.ModelHelpers do
  use CodeCorps.Web, :model

  import CodeCorps.ControllerHelpers

  def generate_slug(changeset, value_key, slug_key) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, value} = Map.fetch(changes, value_key)
        put_change(changeset, slug_key, Inflex.parameterize(value))
      _ ->
        changeset
    end
  end

  def member_filter(query, %{"filter" => %{"id" => id_list}}) do
    ids = id_list |> coalesce_id_string
    query |> where([om], om.member_id in ^ids)
  end
  def member_filter(query, _), do: query

  def organization_filter(query, %{"organization_id" => organization_id}) do
    query |> where([om], om.organization_id == ^organization_id)
  end
  def organization_filter(query, _), do: query

  def role_filter(query, %{"role" => roles}) do
    roles = roles |> coalesce_string
    query |> where([om], om.role in ^roles)
  end
  def role_filter(query, _), do: query
end
