defmodule CodeCorps.JsonAPIHelpers do
  def build_json_payload(attrs = %{}) do
    with attributes <- build_attributes(attrs),
         relationships <- build_relationships(attrs)
    do
      build_payload(attributes, relationships)
    end
  end

  defp build_attributes(attrs) do
    attrs
    |> Enum.filter(&is_attribute(&1))
    |> Enum.reduce(%{}, &insert_string_key(&1, &2))
  end

  defp build_relationships(attrs) do
    attrs
    |> Enum.filter_map(&is_relationship(&1), &build_relationship(&1))
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  defp build_relationship({key, record}) do
    with id <- record.id,
         type <- model_name_as_string(record)
    do
      %{} |> Map.put(Atom.to_string(key), %{"data" => %{"id" => id, "type" => type}})
    end
  end

  defp is_attribute({_key, %DateTime{} = _val}), do: true
  defp is_attribute({_key, val}) when is_map(val), do: false
  defp is_attribute(_), do: true

  defp is_relationship(tupple), do: !is_attribute(tupple)

  defp model_name_as_string(record) do
    record.__struct__
    |> Module.split
    |> List.last
    |> String.downcase
  end

  defp insert_string_key({key, value}, map) do
    with string_key <- Atom.to_string(key), do: Map.put(map, string_key, value)
  end

  defp build_payload(attributes, relationships) do
    %{
      "data" => %{
        "attributes" => attributes,
        "relationships" => relationships
      }
    }
  end
end
