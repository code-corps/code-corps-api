defmodule CodeCorps.GitHub.FailureAPI do
  @moduledoc ~S"""
  A basic GitHub API mock which returns a 401 forbidden for all requests.

  Should be good enough for any tests that simply assert a piece of code is able
  to recover from a generic request error.

  For any tests that cover handling of specific errors, a non-default API should
  be defined inline.

  Since our GitHub requests are often forced to start with an installation
  access token request, that one is set to succeed here as well.
  """
  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.SuccessAPI

  def request(method, url, body, headers, options) do
    case {method, url} |> for_access_token?() do
      true -> SuccessAPI.request(method, url, body, headers, options)
      false ->
        send(self(), {method, url, body, headers, options})
        {:ok, body} = load_endpoint_fixture("forbidden") |> Poison.encode
        {:ok, %HTTPoison.Response{status_code: 401, body: body}}
    end
  end

  defp for_access_token?({:post, url}), do: url |> access_token_url?()
  defp for_access_token?({_method, _url}), do: false

  defp access_token_url?("https://api.github.com/" <> path), do: path |> String.split("/") |> access_token_parts?()
  defp access_token_url?(_), do: false

  defp access_token_parts?(["installations", _, "access_tokens"]), do: true
  defp access_token_parts?(_), do: false
end
