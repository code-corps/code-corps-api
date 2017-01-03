defmodule CodeCorps.MapUtils do
  def rename(map, old_key, new_key) do
    map
    |> Map.put(new_key, map |> Map.get(old_key))
    |> Map.delete(old_key)
  end

  def keys_to_string(map), do: stringify_keys(map)

  # Intercept incoming %DateTime arguments; otherwise they will match %{}
  defp stringify_keys(%DateTime{} = val), do: val
  # Goes through a list and stringifies keys of any map member
  defp stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} -> {stringify_key(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end
  defp stringify_keys([head | rest]), do: [stringify_keys(head) | stringify_keys(rest)]
  # Default
  defp stringify_keys(val), do: val

  defp stringify_key(k) when is_atom(k), do: Atom.to_string(k)
  defp stringify_key(k), do: k
end
