defmodule CodeCorps.GitHubEventsController do
  use CodeCorps.Web, :controller

  alias CodeCorps.GitHub.Webhook.{
    EventSupport, Processor
  }

  def create(conn, event_payload) do
    event_type = conn |> get_event_type()

    case event_type |> EventSupport.status do
      :supported ->
        Processor.process_async(event_type, conn |> get_delivery_id, event_payload)
        conn |> send_resp(200, "")
      :unsupported ->
        conn |> send_resp(202, "")
    end
  end

  defp get_event_type(conn) do
    header = Application.get_env(:code_corps, :github_event_type_header)
    conn |> get_req_header(header) |> List.first
  end

  defp get_delivery_id(conn) do
    header = Application.get_env(:code_corps, :github_event_id_header)
    conn |> get_req_header(header) |> List.first
  end
end
