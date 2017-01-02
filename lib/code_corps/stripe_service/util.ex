defmodule CodeCorps.StripeService.Util do
  @moduledoc """
  Utility functions for handling the Stripe API.
  """

  @doc """
  Takes a source map and a list of tuples representing how the source map
  should be transformed into a new map, then applies the mapping
  operation on each field
  """
  def transform_map(api_map, mapping), do: mapping |> Enum.reduce(%{}, &map_field(&1, &2, api_map))

  def transform_attributes(attributes, mapping) do
    attributes_map = map_keys_to_atoms(attributes)
    mapping |> Enum.reduce(%{}, &map_attribute(&1, &2, attributes_map))
  end

  defp map_keys_to_atoms(m) do
    result = Enum.map(m, fn
      {k, v} when is_binary(k)  ->
        a = String.to_existing_atom(k)
        {a, v}
      entry ->
        entry
    end)
    result |> Enum.into(%{})
  end

  defp map_attribute({source_field, target_path}, target_map, source_map) do
    value = source_map |> Map.get(source_field)
    list = target_path |> Enum.reverse
    result = put_value(list, value, %{})
    deep_merge(target_map, result)
  end

  defp put_value(_, value, map) when is_nil(value), do: map
  defp put_value([head | tail], value, map) do
    new_value = Map.put(%{}, head, value)
    put_value(tail, new_value, map)
  end
  defp put_value([], new_value, _map), do: new_value

  defp deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, _left, right) do
    right
  end

  # Takes a tuple which contains a target field and a source path,
  # then puts value on the source path from the source map
  # into to target map under the target field name.
  # Example:
  #
  # - `source_map` is `%{path: %{to: %{field: some_value}} }
  # - `source_path` is `[:path, :to, :field]`
  # - `target_field` is `:path_to_field`
  # - `some_value` will be put into `target_map`, under the key `:path_to_field`
  defp map_field({target_field, source_path}, target_map, source_map) do
    value = get_in(source_map, source_path)
    target_map |> Map.put(target_field, value)
  end
end
