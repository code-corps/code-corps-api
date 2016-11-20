defmodule CodeCorps.MapUtils do
  def rename(map, old_key, new_key) do
    map
    |> Map.put(new_key, map |> Map.get(old_key))
    |> Map.delete(old_key)
  end

  def keys_to_string(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {Atom.to_string(key), val}
        true -> {key, val}
      end
    end
  end
end
