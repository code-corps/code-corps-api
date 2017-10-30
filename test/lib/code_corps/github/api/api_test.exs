defmodule CodeCorps.GitHub.APITest do
  @moduledoc false

  use ExUnit.Case

  alias CodeCorps.GitHub.{API, APIError, HTTPClientError}

  describe "request/5" do
    defmodule MockAPI do
      def request(_method, "/error", _body, _headers, _opts) do
        {:error, %HTTPoison.Error{reason: "Intentional Test Error"}}
      end
      def request(_method, url, _body, _headers, _opts) do
        response =
          %HTTPoison.Response{}
          |> Map.put(:body, url |> body())
          |> Map.put(:request_url, url)
          |> Map.put(:status_code, url |> code)

        {:ok, response}
      end

      defp body("/200"), do:  %{"bar" => "baz"} |> Poison.encode!
      defp body("/200-bad"), do: "bad"
      defp body("/400"), do: %{"message" => "baz"} |> Poison.encode!
      defp body("/400-bad"), do: "bad"
      defp body("/404"), do: %{"message" => "Not Found"} |> Poison.encode!

      defp code("/200" <> _rest), do: 200
      defp code("/400" <> _rest), do: 400
      defp code("/404" <> _rest), do: 404
    end

    setup do
      old_mock = Application.get_env(:code_corps, :github)
      Application.put_env(:code_corps, :github, MockAPI)

      on_exit fn ->
        Application.put_env(:code_corps, :github, old_mock)
      end

      :ok
    end

    test "handles a 200..299 response" do
      {:ok, response} = API.request(:get, "/200", %{}, [], [])
      assert response == %{"bar" => "baz"}
    end

    test "handles a decode error for a 200..299 response" do
      {:error, response} = API.request(:get, "/200-bad", %{}, [], [])
      assert response == HTTPClientError.new([reason: :body_decoding_error])
    end

    test "handles a 404 response" do
      {:error, response} = API.request(:get, "/404", %{}, [], [])
      assert response ==
        APIError.new({404, %{"message" => "{\"message\":\"Not Found\"}"}})
    end

    test "handles a 400 response" do
      {:error, response} = API.request(:get, "/400", %{}, [], [])
      assert response == APIError.new({400, %{"message" => "baz"}})
    end

    test "handles a decode error for a 400..599 response" do
      {:error, response} = API.request(:get, "/400-bad", %{}, [], [])

      assert response == HTTPClientError.new([reason: :body_decoding_error])
    end

    test "handles a client error" do
      {:error, %HTTPClientError{reason: reason}} =
        API.request(:get, "/error", %{}, [], [])

      assert reason == "Intentional Test Error"
    end
  end

  describe "get_all/3" do
    defmodule MockPaginationAPI do
      def request(:head, "/one-page", _body, _headers, _opts) do
        {:ok, %HTTPoison.Response{headers: [], status_code: 200}}
      end
      def request(:head, "/two-pages", _body, _headers, _opts) do
        next = '<two-pages/?page=2>; rel="next"'
        last = '<two-pages/?page=2>; rel="last"'

        headers = [{"Link", [next, last] |> Enum.join(", ")}]
        {:ok, %HTTPoison.Response{headers: headers, status_code: 200}}
      end
      def request(:get, "/one-page", _body, _headers, [params: [page: 1]]) do
        body = [1] |> Poison.encode!
        {:ok, %HTTPoison.Response{body: body, status_code: 200}}
      end
      def request(:get, "/two-pages", _body, _headers, [params: [page: 1]]) do
        body = [1, 2] |> Poison.encode!
        {:ok, %HTTPoison.Response{body: body, status_code: 200}}
      end
      def request(:get, "/two-pages", _body, _headers, [params: [page: 2]]) do
        body = [3] |> Poison.encode!
        {:ok, %HTTPoison.Response{body: body, status_code: 200}}
      end
    end

    setup do
      old_mock = Application.get_env(:code_corps, :github)
      Application.put_env(:code_corps, :github, MockPaginationAPI)

      on_exit fn ->
        Application.put_env(:code_corps, :github, old_mock)
      end

      :ok
    end

    test "works when there's just one page" do
      assert [1] == API.get_all("/one-page", [], [])
    end

    test "works with multiple pages" do
      assert [1, 2, 3] == API.get_all("/two-pages", [], [])
    end
  end
end
