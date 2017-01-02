defmodule CodeCorps.ConnUtils do
  def extract_ip(%Plug.Conn{} = conn) do
    conn.remote_ip |> Tuple.to_list |> Enum.join(".")
  end

  def extract_user_agent(%Plug.Conn{} = conn) do
    conn |> Plug.Conn.get_req_header("user-agent") |> List.first
  end
end
