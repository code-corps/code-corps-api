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
