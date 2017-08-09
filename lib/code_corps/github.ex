defmodule CodeCorps.GitHub do

  alias CodeCorps.Github.JWT

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
  @type headers :: %{String.t => String.t} | %{}
  @type body :: {:multipart, list} | map
  @typep http_success :: {:ok, integer, [{String.t, String.t}], String.t}
  @typep http_failure :: {:error, term}

  @type api_error_struct :: APIError.t | HTTPClientError.t | Poison.DecodeError.t

  @spec get_base_url() :: String.t
  defp get_base_url() do
    Application.get_env(:code_corps, :github_base_url) || "https://api.github.com/"
  end

  @spec get_token_url() :: String.t
  defp get_token_url() do
    Application.get_env(:code_corps, :github_oauth_url) || "https://github.com/login/oauth/access_token"
  end

  @spec use_pool?() :: boolean
  defp use_pool?() do
    Application.get_env(:code_corps, :github_api_use_connection_pool)
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(existing_headers) do
    Map.merge(%{"Accept" => "application/vnd.github.machine-man-preview+json"}, existing_headers)
  end

  @spec add_access_token_header(headers, String.t | nil) :: headers
  defp add_access_token_header(existing_headers, nil), do: existing_headers
  defp add_access_token_header(existing_headers, access_token) do
    Map.put(existing_headers, "Authorization", "token #{access_token}")
  end

  @spec add_jwt_header(headers) :: headers
  defp add_jwt_header(existing_headers) do
    Map.put(existing_headers, "Authorization", "Bearer #{JWT.generate}")
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

  require Logger

  @doc """
  A low level utility function to make a direct request to the GitHub API.
  """
  @spec request(body, method, String.t, headers, list) :: {:ok, map} | {:error, api_error_struct}
  def request(body, method, endpoint, headers, opts) do
    {access_token, opts} = Keyword.pop(opts, :access_token)

    base_url = get_base_url()
    req_url = base_url <> endpoint
    req_body = body |> Poison.encode!
    req_headers =
      headers
      |> add_default_headers()
      |> add_access_token_header(access_token)
      |> Map.to_list()

    req_opts =
      opts
      |> add_default_options()

    method
    |> :hackney.request(req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @doc """
  A low level utility function to fetch a GitHub user's OAuth access token
  """
  @spec user_access_token_request(String.t, String.t) :: {:ok, map} | {:error, api_error_struct}
  def user_access_token_request(code, state) do
    req_url = get_token_url()
    req_body = code |> build_access_token_params(state) |> Poison.encode!
    req_headers =
      %{"Accept" => "application/json", "Content-Type" => "application/json"}
      |> add_default_headers()
      |> Map.to_list()

    req_opts =
      []
      |> add_default_options()

    :hackney.request(:post, req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @doc """
  A low level utility function to make an authenticated request to the
  GitHub API on behalf of a GitHub App or integration
  """
  @spec authenticated_integration_request(body, method, String.t, headers, list) :: {:ok, map} | {:error, api_error_struct}
  def authenticated_integration_request(body, method, endpoint, headers, opts) do
    base_url = get_base_url()
    req_url = base_url <> endpoint
    req_body = body |> Poison.encode!
    req_headers =
      headers
      |> add_default_headers()
      |> add_jwt_header()
      |> Map.to_list()

    req_opts =
      opts
      |> add_default_options()

    :hackney.request(method, req_url, req_headers, req_body, req_opts)
    |> handle_response()
  end

  @spec handle_response(http_success | http_failure) :: {:ok, map} | {:error, api_error_struct}
  defp handle_response({:ok, status, _headers, body}) when status in 200..299 do
    body |> Poison.decode
  end
  defp handle_response({:ok, 404, _headers, body}) do
    {:error, APIError.new({404, %{"message" => body}})}
  end
  defp handle_response({:ok, status, _headers, body}) when status in 400..599 do
    case body |> Poison.decode do
      {:ok, json} -> {:error, APIError.new({status, json})}
      {:error, error} -> {:error, error}
    end
  end
  defp handle_response({:error, reason}) do
    {:error, HTTPClientError.new(reason: reason)}
  end
end
