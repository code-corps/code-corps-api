defmodule CodeCorps.GitHub.API.Errors.PaginationError do
  alias CodeCorps.GitHub.{APIError, HTTPClientError}

  @type t :: %__MODULE__{
    api_errors: list,
    client_errors: list,
    message: String.t,
    retrieved_pages: list
  }

  defstruct [
    api_errors: [],
    client_errors: [],
    message: "One or more pages failed to retrieve when paginating GitHub API resources",
    retrieved_pages: []
  ]

  @spec new({list, list}) :: t
  def new({pages, errors}) do
    %__MODULE__{
      api_errors: errors |> Enum.filter(&api_error?/1),
      client_errors: errors |> Enum.filter(&client_error?/1),
      retrieved_pages: pages
    }
  end

  @spec api_error?(APIError.t | any) :: boolean
  defp api_error?(%APIError{}), do: true
  defp api_error?(_), do: false

  @spec client_error?(HTTPClientError.t | any) :: boolean
  defp client_error?(%HTTPClientError{}), do: true
  defp client_error?(_), do: false
end
