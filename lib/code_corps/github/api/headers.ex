defmodule CodeCorps.GitHub.API.Headers do
  alias CodeCorps.GitHub.API.JWT

  @typep header :: {String.t, String.t}
  @type t :: list(header)

  @spec user_request(%{String.t => String.t} | %{}, list) :: t
  def user_request(%{} = headers, options) do
    headers
    |> add_default_headers()
    |> add_access_token_header(options)
    |> Map.to_list()
  end

  @spec integration_request(%{String.t => String.t} | %{}) :: t
  def integration_request(%{} = headers) do
    headers
    |> add_default_headers()
    |> add_jwt_header()
    |> Map.to_list()
  end

  @spec access_token_request :: t
  def access_token_request do
    %{"Accept" => "application/json", "Content-Type" => "application/json"}
    |> add_default_headers()
    |> Map.to_list()
  end

  @spec add_default_headers(%{String.t => String.t}) :: %{String.t => String.t}
  defp add_default_headers(%{} = headers) do
    Map.merge(%{"Accept" => "application/vnd.github.machine-man-preview+json"}, headers)
  end

  @spec add_access_token_header(%{String.t => String.t}, list) :: %{String.t => String.t}
  defp add_access_token_header(%{} = headers, [access_token: nil]), do: headers
  defp add_access_token_header(%{} = headers, [access_token: access_token]) do
    Map.put(headers, "Authorization", "token #{access_token}")
  end
  defp add_access_token_header(headers, []), do: headers

  @spec add_jwt_header(%{String.t => String.t}) :: %{String.t => String.t}
  defp add_jwt_header(%{} = headers) do
    Map.put(headers, "Authorization", "Bearer #{JWT.generate}")
  end
end
