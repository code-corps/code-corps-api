defmodule CodeCorps.ModelHelpers do
  use CodeCorps.Web, :model

  import CodeCorps.ControllerHelpers

  def generate_slug(changeset, value_key, slug_key) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        case Map.fetch(changes, value_key) do
          {:ok, value} -> put_change(changeset, slug_key, Inflex.parameterize(value))
          _ -> changeset
        end
      _ ->
        changeset
    end
  end

  # filters

  def id_filter(query, %{"filter" => %{"id" => id_list}}) do
    ids = id_list |> coalesce_id_string
    query |> where([object], object.id in ^ids)
  end
  def id_filter(query, _), do: query

  def newest_first_filter(query), do: query |> order_by([desc: :inserted_at])

  def limit_filter(query, %{"limit" => count}) do
    query |> limit(^count)
  end
  def limit_filter(query, _), do: query

  def number_as_id_filter(query, %{"id" => number}) do
    query |> where([object], object.number == ^number)
  end
  def number_as_id_filter(query, _), do: query

  def organization_filter(query, %{"organization_id" => organization_id}) do
    query |> where([object], object.organization_id == ^organization_id)
  end
  def organization_filter(query, _), do: query

  def post_type_filter(query, %{"post_type" => post_type_list}) do
    post_types = post_type_list |> coalesce_string
    query |> where([object], object.post_type in ^post_types)
  end
  def post_type_filter(query, _), do: query

  def post_status_filter(query, %{"status" => status}) do
    query |> where([object], object.status == ^status)
  end
  def post_status_filter(query, _), do: query

  def post_filter(query, %{"post_id" => post_id}) do
    query |> where([object], object.post_id == ^post_id)
  end
  def post_filter(query, _), do: query

  def project_filter(query, %{"project_id" => project_id}) do
    query |> where([object], object.project_id == ^project_id)
  end
  def project_filter(query, _), do: query

  def role_filter(query, %{"role" => roles}) do
    roles = roles |> coalesce_string
    query |> where([object], object.role in ^roles)
  end
  def role_filter(query, _), do: query

  def title_filter(query, %{"query" => title}) do
    query |> where([object], ilike(object.title, ^"%#{title}%"))
  end
  def title_filter(query, _), do: query

  # end filters

  # finders

  def slug_finder(query, slug) do
    query |> CodeCorps.Repo.get_by!(slug: slug |> String.downcase)
  end

  # end finders
end
