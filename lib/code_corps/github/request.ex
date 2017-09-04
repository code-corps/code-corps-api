defmodule CodeCorps.GitHub.Request do
  alias CodeCorps.GitHub

  @spec retrieve(String.t, Keyword.t) :: GitHub.response
  def retrieve(endpoint, opts), do: GitHub.request(:get, endpoint, %{}, %{}, opts)
end
