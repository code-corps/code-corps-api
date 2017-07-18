defmodule CodeCorps.Adapter.MapTransformer do
  @moduledoc ~S"""
  Module used to transform maps for the purposes of various adapters used by the
  application.
  """

  @typedoc ~S"""
  A format representing how a single key should be mapped from a source. The
  actual format is a 2 element tuple.

  The first element is the destination key in the output map.

  The second element is a list of keys representing the nested path to the key
  in the source map.

  For example, the tuple:

  `{:target_path, ["nested", "path", "to", "source"]}`

  Means that, from the source map, we need to take the nested value under
  "nested" => "path" => "to" => "source" and then put it into the output map,
  as a value for the key ":target_path".
  """
  @type key_mapping :: {atom, list[atom]}

  @typedoc """

  """
  @type mapping :: list(key_mapping)

  @doc ~S"""
  Takes a source map and a list of tuples representing how the source map
  should be transformed into a new map, then applies the mapping
  operation on each field.
  """
  @spec transform(map, mapping) :: map
  def transform(%{} = source_map, mapping) when is_list(mapping) do
    mapping |> Enum.reduce(%{}, &map_field(&1, &2, source_map))
  end

  @spec map_field(key_mapping, map, map) :: map
  defp map_field({target_field, source_path}, %{} = target_map, %{} = source_map) do
    value = get_in(source_map, source_path)
    target_map |> Map.put(target_field, value)
  end

  @doc ~S"""
  Performs the inverse of `&transform/2`
  """
  @spec transform_inverse(map, mapping) :: map
  def transform_inverse(%{} = map, mapping) when is_list(mapping) do
    mapping |> Enum.reduce(%{}, &map_field_inverse(&1, &2, map))
  end

  @spec map_field_inverse(key_mapping, map, map) :: map
  defp map_field_inverse({source_field, target_path}, target_map, source_map) do
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
end
