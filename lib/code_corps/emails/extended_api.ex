defmodule CodeCorps.Emails.ExtendedAPI do
  @moduledoc ~S"""
  Serves as an extension of the SparkPost API provided by the elixir-sparkpost
  library, for features the external package does not support yet

  We should eliminate this module and instead push a PR to add these
  features to elixir-sparkpost
  """

  use HTTPoison.Base

  alias SparkPost.{Transmission, Endpoint}

  @base_url "https://api.sparkpost.com/api/v1"

  @spec process_url(String.t) :: String.t
  def process_url(url), do: @base_url <> url

  @spec process_request_headers(list) :: list
  def process_request_headers(headers) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", System.get_env("SPARKPOST_API_KEY")}
    ] ++ headers
  end

  @spec process_request_body(String.t) :: map
  def process_request_body(body), do: body |> Poison.encode!

  @spec process_response_body(String.t) :: map
  def process_response_body(body), do: body |> Poison.decode!

  @spec create_template(map, list, list) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def create_template(body \\ %{}, headers \\ [], options \\ []) do
    start()
    post("/templates", body, headers, options)
  end

  @spec update_template(String.t, map, list, list) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def update_template(id, body \\ %{}, headers \\ [], options \\ []) do
    start()
    put("/templates/#{id}", body, headers, options)
  end

  @spec send_transmission(%Transmission{}) :: %Transmission.Response{} | %Endpoint.Error{}
  def send_transmission(%Transmission{} = transmission) do
    transmission |> SparkPost.Transmission.send
  end
end
