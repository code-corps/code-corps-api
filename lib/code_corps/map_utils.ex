defmodule CodeCorps.MapUtils do
  def rename(map, old_key, new_key) do
    map
    |> Map.put(new_key, map |> Map.get(old_key))
    |> Map.delete(old_key)
  end
end
