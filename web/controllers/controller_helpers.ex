defmodule CodeCorps.ControllerHelpers do
  def coalesce_id_string(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.to_integer(&1))
  end
end
