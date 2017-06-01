defmodule CodeCorps.GitHub.APIContract do
  @moduledoc """
  Defines a contract for a GitHub API module, listing all functions the module
  should implement.

  This contract should be specified as behaviour for the default `GitHub.API`
  module, as well as any custom module we inject in tests.
  """

  @doc """
  Receives a code string, created on the client side of the GitHub connect
  process.

  Returns one of:

  - an `:ok` tuple indicating a successful connect process, where
  the second element is the OAuth token string
  - an `:error` tuple, where the second element is an error message or a struct
  """
  @callback connect(code :: String.t) :: {:ok, auth_token :: String.t} | {:error, error :: String.t}
end
