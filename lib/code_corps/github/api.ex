defmodule CodeCorps.GitHub.API do
  @moduledoc """
  The boundary module which communicates with the GitHub API using either
  direct requests, or through Tentacat.
  """
  @behaviour CodeCorps.GitHub.APIContract

  @client_secret Application.get_env(:code_corps, :github_oauth_client_secret)
  @client_id Application.get_env(:code_corps, :github_oauth_client_id)

  @base_connect_params %{
    client_id: @client_id,
    client_secret: @client_secret
  }

  @doc """
  Receives a code generated through the client-side GitHub connect process
  and posts it to GitHub.

  Returns either an {:ok, access_token}, or an {:error, error_message}.
  """
  @spec connect(String.t) :: {:ok, String.t} | {:error, String.t}
  def connect(code) do
    with {:ok, %HTTPoison.Response{body: response}} <- code |> build_connect_params() |> do_connect(),
      {:ok, %{"access_token" => access_token}} <- response |> Poison.decode
    do
      {:ok, access_token}
    else
      {:ok, %{"error" => error}} -> {:error, error}
    end
  end

  @connect_url "https://github.com/login/oauth/access_token"

  @spec do_connect(map) :: {:ok, HTTPoison.Response.t | HTTPoison.AsyncResponse.t} | {:error, HTTPoison.Error.t}
  defp do_connect(params) do
    HTTPoison.post(@connect_url, "", [{"Accept", "application/json"}, {"Content-Type", "application/json"}], [params: params])
  end

  @spec build_connect_params(String.t) :: map
  defp build_connect_params(code) do
    @base_connect_params |> Map.put(:code, code)
  end
end
