defmodule CodeCorps.ConnUtilsTest do
  use CodeCorps.ConnCase

  alias CodeCorps.ConnUtils

  defp conn_with_ip(ip) do
    %Plug.Conn{remote_ip: ip}
  end

  describe "extract_ip/1" do
    test "extracts IP address from the request properly" do
      assert conn_with_ip({151, 236, 219, 228}) |> ConnUtils.extract_ip == "151.236.219.228"
    end
  end

  describe "extract_user_agent/1" do
    test "extracts User Agent from the request properly", %{conn: conn} do
      assert conn |> put_req_header("user-agent", "Some agent") |> ConnUtils.extract_user_agent == "Some agent"
    end
  end
end
