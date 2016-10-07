defmodule CodeCorps.JsonPayloadStrategy do
  use ExMachina.Strategy, function_name: :json_payload

  def handle_json_payload(record, opts) do
    record
    |> get_model_name_as_string
    |> get_view(opts)
    |> serialize(record)
  end

  defp get_model_name_as_string(record), do: record.__struct__ |> Module.split |> List.last
  defp get_view(_, %{serializer: view}), do: view
  defp get_view(model_name, _), do: ["CodeCorps", "#{model_name}View"] |> Module.concat
  defp serialize(view, record), do: apply(view, :render, ["show.json-api", [data: record]])
end
