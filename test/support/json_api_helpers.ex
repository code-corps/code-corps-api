defmodule CodeCorps.JsonAPIHelpers do
  def build_json_payload(attrs = %{}) do
    with attributes <- build_attributes(attrs),
         relationships <- build_relationships(attrs)
    do
      %{
        "data" => %{
          "attributes" => attributes,
          "relationships" => relationships
        }
      }
    end
  end

  defp build_attributes(attrs) do
    attrs
    |> Enum.filter(&is_attribute(&1))
    |> Enum.reduce(%{}, &add_attribute(&1, &2))
  end

  defp build_relationships(attrs) do
    attrs
    |> Enum.filter_map(&is_relationship(&1), &build_relationship(&1))
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  defp build_relationship({atom_key, record}) do
    with id <- record.id |> to_correct_type(),
         type <- record |> model_name_as_string(),
         string_key = atom_key |> Atom.to_string
    do
      %{} |> Map.put(string_key, %{"data" => %{"id" => id, "type" => type}})
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

  defp add_attribute({key, value}, %{} = attrs) do
    attrs |> Map.put(key |> Atom.to_string, value)
  end

  defp to_correct_type(value) when is_integer(value), do: value |> Integer.to_string
  defp to_correct_type(value), do: value
end
