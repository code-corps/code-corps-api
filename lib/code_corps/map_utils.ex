defmodule CodeCorps.MapUtils do
  def rename(map, old_key, new_key) do
    map
    |> Map.put(new_key, map |> Map.get(old_key))
    |> Map.delete(old_key)
  end

  def keys_to_string(map), do: stringify_keys(map)

  # Goes through a list and stringifies keys of any map member
  def stringify_keys(nil), do: nil
  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {stringify_key(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end
  def stringify_keys([head | rest]), do: [stringify_keys(head) | stringify_keys(rest)]
  # Default
  def stringify_keys(not_a_map), do: not_a_map

  def stringify_key(k) when is_atom(k), do: Atom.to_string(k)
  def stringify_key(k), do: k

end
