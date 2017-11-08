defmodule CodeCorps.GitHub.API.GatewayTest do
  @moduledoc false

  use ExUnit.Case

  alias CodeCorps.GitHub.API.Gateway

  alias Plug.Conn
  alias HTTPoison.Response

  @port 12345
  @endpoint "http://localhost" |> URI.merge("") |> Map.put(:port, @port) |> URI.to_string
  @body %{"bar" => "baz"} |> Poison.encode!
  @url @endpoint |> URI.merge("/foo") |> URI.to_string

  setup do
    bypass = Bypass.open(port: @port)
    {:ok, bypass: bypass}
  end

  describe "request/5" do
    [200, 201, 302, 401, 404, 500] |> Enum.each(fn code ->
      @code code

      test "returns a HTTPoison.Response in case of #{code}", %{bypass: bypass} do
        Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: req_headers} = conn ->
          assert {"foo", "bar"} in req_headers
          conn |> Conn.resp(@code, @body)
        end)

        {:ok, %Response{} = response} =
          Gateway.request(:get, @url, @body, [{"foo", "bar"}], [])

        assert response.body == @body
        assert response.status_code == @code
        assert response.request_url == @url
      end
    end)
  end
end
