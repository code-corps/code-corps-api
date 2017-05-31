defmodule CodeCorps.Github.APIContract do
  @moduledoc """
  Defines a contract for a github API module, listing all functions the module
  should implement.

  This contract should be specified as behaviour for the default `Github.API`
  module, as well as any custom module we inject in tests.
  """

  @doc """
  Receives a code string, created in the client part of the github connect process,
  returns either an :ok tupple indicating a successful connect process, where
  the second element is the auth token string, or an :error tuple, where the
  second element is an error message, or a struct
  """
  @callback connect(code :: String.t) :: {:ok, auth_token :: String.t} | {:error, error :: String.t}
end
