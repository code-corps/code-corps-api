defmodule CodeCorps.SparkPost.ExtendedAPI do
  @moduledoc """
  Serves as an extension of the SparkPost API provided by the elixir-sparkpost
  library, for features the external package does not support yet

  We should eliminate this module and instead push a PR to add these
  features to elixir-sparkpost
  """

  use HTTPoison.Base

  @base_url "https://api.sparkpost.com/api/v1"

  def process_url(url), do: @base_url <> url

  def process_request_headers(headers) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", System.get_env("SPARKPOST_API_KEY")}
    ] ++ headers
  end

  def process_request_body(body), do: body |> Poison.encode!
  def process_response_body(body), do: body |> Poison.decode!

  def create_template(body \\ %{}, headers \\ [], options \\ []) do
    start()
    post("/templates", body, headers, options)
  end

  def update_template(id, body \\ %{}, headers \\ [], options \\ []) do
    start()
    put("/templates/#{id}", body, headers, options)
  end

  def send_transmission(content) do
    SparkPost.Transmission.send(content)
  end
end
