defmodule CodeCorps.GitHub.APITest do
  @moduledoc false

  use ExUnit.Case

  alias CodeCorps.GitHub.{API, APIError, HTTPClientError}
  alias Plug.Conn

  @port 12345
  @endpoint "http://localhost" |> URI.merge("") |> Map.put(:port, @port) |> URI.to_string
  @body %{"bar" => "baz"} |> Poison.encode!

  defp url_for(path) do
    URI.merge(@endpoint, path) |> URI.to_string
  end

  setup do
    bypass = Bypass.open(port: @port)
    {:ok, bypass: bypass}
  end

  describe "request/5" do
    test "handles a 200..299 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: headers} = conn ->
        assert {"foo", "bar"} in headers
        conn |> Conn.resp(200, @body)
      end)

      {:ok, response} = API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body])
      assert response == (@body |> Poison.decode!)
    end

    test "handles a decode error for a 200..299 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: headers} = conn ->
        assert {"foo", "bar"} in headers
        conn |> Conn.resp(200, "foo")
      end)

      {:error, response} = API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body])
      assert response == HTTPClientError.new([reason: :body_decoding_error])
    end

    test "handles a 404 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: headers} = conn ->
        assert {"foo", "bar"} in headers
        conn |> Conn.resp(404, @body)
      end)

      {:error, response} = API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body])
      assert response == APIError.new({404, %{"message" => @body}})
    end

    @generic_error %{"message" => "foo"} |> Poison.encode!

    test "handles a 400 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: headers} = conn ->
        assert {"foo", "bar"} in headers
        conn |> Conn.resp(400, @generic_error)
      end)

      {:error, response} = API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body])
      assert response == APIError.new({400, @generic_error |> Poison.decode!})
    end

    test "handles a decode error for a 400..599 response", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/foo", fn %Conn{req_headers: headers} = conn ->
        assert {"foo", "bar"} in headers
        conn |> Conn.resp(400, "foo")
      end)

      {:error, response} = API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body])
      assert response == HTTPClientError.new([reason: :body_decoding_error])
    end

    test "handles a network error", %{bypass: bypass} do
      bypass |> Bypass.down
      # bypass is simulating a connection timeout error, so we need to set a
      # small value for hackney's request to avoid test hanging
      {:error, %HTTPClientError{reason: reason}} =
        API.request(:get, url_for("/foo"), [{"foo", "bar"}], @body, [:with_body, connect_timeout: 15])
      bypass |> Bypass.up

      # bypass wil localy throw a :connect_timeout when down,
      # but it will be an _econnrefused on circle
      # we just care that a client error is handled by creating the
      # proper struct
      assert reason in [:connect_timeout, :econnrefused]
    end
  end
end
