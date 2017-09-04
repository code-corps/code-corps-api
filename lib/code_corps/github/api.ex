defmodule CodeCorps.GitHub.API do
  alias CodeCorps.{
    GitHub,
    GitHub.APIError,
    GitHub.HTTPClientError
  }

  @spec request(GitHub.method, String.t, GitHub.headers, GitHub.body, list) :: GitHub.response
  def request(method, url, headers, body, options) do
    method
    |> :hackney.request(url, headers, body, options)
    |> marshall_response()
  end

  @typep http_success :: {:ok, integer, [{String.t, String.t}], String.t}
  @typep http_failure :: {:error, term}

  @spec marshall_response(http_success | http_failure) :: GitHub.response
  defp marshall_response({:ok, status, _headers, body}) when status in 200..299 do
    case body |> Poison.decode do
      {:ok, json} ->
        {:ok, json}
      {:error, {_decoding_error, _decoding_value}} ->
        marshall_response({:error, :body_decoding_error})
    end
  end
  defp marshall_response({:ok, 404, _headers, body}) do
    {:error, APIError.new({404, %{"message" => body}})}
  end
  defp marshall_response({:ok, status, _headers, body}) when status in 400..599 do
    case body |> Poison.decode do
      {:ok, json} ->
        {:error, APIError.new({status, json})}
      {:error, {_decoding_error, _decoding_value}} ->
        marshall_response({:error, :body_decoding_error})
    end
  end
  defp marshall_response({:error, reason}) do
    {:error, HTTPClientError.new(reason: reason)}
  end
end
