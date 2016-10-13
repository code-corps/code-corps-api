defmodule CodeCorps.Helpers.Query do
  import CodeCorps.Helpers.String, only: [coalesce_id_string: 1, coalesce_string: 1]
  import Ecto.Query, only: [where: 3]

  def id_filter(query, id_list) do
    ids = id_list |> coalesce_id_string
    query |> where([object], object.id in ^ids)
  end

  def organization_filter(query, organization_id) do
    query |> where([object], object.organization_id == ^organization_id)
  end

  def role_filter(query, roles_list) do
    roles = roles_list |> coalesce_string
    query |> where([object], object.role in ^roles)
  end
end
