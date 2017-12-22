defmodule CodeCorps.Emails.API do
  @moduledoc ~S"""
  A wrapper for the SparkPost API.

  All API requests should go through functions in this module.
  """
  require Logger

  @type transmission_result :: {:ok, %SparkPost.Transmission.Response{}} |
                               {:error, %SparkPost.Endpoint.Error{}}

  defp api, do: Application.get_env(:code_corps, :sparkpost)

  def create_template(body \\ %{}, headers \\ [], options \\ []) do
    body |> api().create_template(headers, options) |> marshall_response()
  end

  def update_template(id, body \\ %{}, headers \\ [], options \\ []) do
    id |> api().update_template(body, headers, options) |> marshall_response()
  end

  @doc ~S"""
  Sends a transmission using the provided email map
  """
  @spec send_transmission(%SparkPost.Transmission{}) :: transmission_result
  def send_transmission(%SparkPost.Transmission{} = content) do
    content |> api().send_transmission() |> marshall_response()
  end

  defp marshall_response(%SparkPost.Transmission.Response{} = response), do: {:ok, response}
  defp marshall_response(%SparkPost.Content.Inline{} = response), do: {:ok, response}
  defp marshall_response(%SparkPost.Endpoint.Error{} = error), do: {:error, error}
  # Extended API responses
  defp marshall_response({:ok, %HTTPoison.Response{status_code: code} = response})
    when code in 200..399, do: {:ok, response}
  defp marshall_response({:ok, %HTTPoison.Response{status_code: code} = response})
    when code in 400..599, do: {:error, response |> build_error()}
  defp marshall_response({:error, %HTTPoison.Error{} = error}), do: {:error, error |> build_error()}

  defp build_error(%HTTPoison.Response{status_code: code, body: %{"errors" => errors}}) do
    %SparkPost.Endpoint.Error{status_code: code, errors: errors}
  end
  defp build_error(%HTTPoison.Error{id: id, reason: reason}) do
    %SparkPost.Endpoint.Error{status_code: nil, errors: [{id, reason}]}
  end
end
