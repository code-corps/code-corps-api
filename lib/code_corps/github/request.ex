defmodule CodeCorps.GitHub.Request do

  alias CodeCorps.GitHub

  @spec retrieve(String.t, Keyword.t) :: {:ok, map} | {:error, GitHub.api_error_struct}
  def retrieve(endpoint, opts), do: retrieve(%{}, endpoint, opts)

  @spec retrieve(map, String.t, Keyword.t) :: {:ok, map} | {:error, GitHub.api_error_struct}
  def retrieve(changes, endpoint, opts) do
    changes
    |> GitHub.request(:get, endpoint, %{}, opts)
  end
end
