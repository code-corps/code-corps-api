defmodule CodeCorps.GitHub do
  alias CodeCorps.GitHub.Headers

  @client_id Application.get_env(:code_corps, :github_app_client_id)
  @client_secret Application.get_env(:code_corps, :github_app_client_secret)

  @base_access_token_params %{
    client_id: @client_id,
    client_secret: @client_secret
  }

  defmodule APIErrorObject do
    @moduledoc """
    Represents an error object from the GitHub API.

    Used in some `APIError`s when the API's JSON response contains an
    `errors` key.

    The full details of error objects can be found in the
    [GitHub API documentation](https://developer.github.com/v3/#client-errors).
    """

    @type t :: %__MODULE__{}

    defstruct [:code, :field, :resource]

    def new(opts) do
      struct(__MODULE__, opts)
    end
  end

  defmodule APIError do
    @moduledoc """
    Represents a client error from the GitHub API.

    You can read more about client errors in the
    [GitHub API documentation](https://developer.github.com/v3/#client-errors).
    """

    defstruct [:documentation_url, :errors, :message, :status_code]

    @type t :: %__MODULE__{
      documentation_url: String.t | nil,
      errors: list | nil,
      message: String.t | nil,
      status_code: pos_integer | nil
    }

    @spec new({integer, map}) :: t
    def new({status_code, %{"message" => message, "errors" => errors}}) do
      errors = Enum.into(errors, [], fn error -> convert_error(error) end)

      %__MODULE__{
        errors: errors,
        message: message,
        status_code: status_code
      }
    end
    def new({status_code, %{"message" => message, "documentation_url" => documentation_url}}) do
      %__MODULE__{
        documentation_url: documentation_url,
        message: message,
        status_code: status_code
      }
    end
    def new({status_code, %{"message" => message}}) do
      %__MODULE__{
        message: message,
        status_code: status_code
      }
    end

    @spec convert_error(map) :: APIErrorObject.t
    defp convert_error(%{"code" => code, "field" => field, "resource" => resource}) do
      APIErrorObject.new([code: code, field: field, resource: resource])
    end
  end

  defmodule HTTPClientError do
    defstruct [:reason, message: """
    The GitHub HTTP client encountered an error while communicating with
    the GitHub API.
    """]

    @type t :: %__MODULE__{}

    def new(opts) do
      struct(__MODULE__, opts)
    end
  end


  @type method :: :get | :post | :put | :delete | :patch

  @type body :: {:multipart, list} | map
  @type headers :: %{String.t => String.t} | %{}
  @type response :: {:ok, map} | {:error, api_error_struct}
  @type api_error_struct :: APIError.t | HTTPClientError.t

  @doc """
  A low level utility function to make a direct request to the GitHub API.
  """
  @spec request(method, String.t, headers, body, list) :: response
  def request(method, endpoint, headers, body, options) do
    api().request(
      method,
      api_url_for(endpoint),
      headers |> Headers.user_request(options),
      body |> Poison.encode!,
      options |> add_default_options()
    )
  end

  @doc """
  A low level utility function to make an authenticated request to the
  GitHub API on behalf of a GitHub App or integration
  """
  @spec integration_request(method, String.t, headers, body, list) :: response
  def integration_request(method, endpoint, headers, body, options) do
    api().request(
      method,
      api_url_for(endpoint),
      headers |> Headers.integration_request,
      body |> Poison.encode!,
      options |> add_default_options()
    )
  end

  @token_url "https://github.com/login/oauth/access_token"

  @doc """
  A low level utility function to fetch a GitHub user's OAuth access token
  """
  @spec user_access_token_request(String.t, String.t) :: response
  def user_access_token_request(code, state) do
    api().request(
      :post,
      @token_url,
      Headers.access_token_request,
      code |> build_access_token_params(state) |> Poison.encode!,
      [] |> add_default_options()
    )
  end

  @spec api :: module
  defp api, do: Application.get_env(:code_corps, :github)

  @api_url "https://api.github.com/"

  @spec api_url_for(String.t) :: String.t
  defp api_url_for(endpoint) when is_binary(endpoint) do
    @api_url |> URI.merge(endpoint) |> URI.to_string
  end

  @spec add_default_options(list) :: list
  defp add_default_options(opts) do
    [:with_body | opts]
  end

  @spec build_access_token_params(String.t, String.t) :: map
  defp build_access_token_params(code, state) do
    @base_access_token_params
    |> Map.put(:code, code)
    |> Map.put(:state, state)
  end
end
