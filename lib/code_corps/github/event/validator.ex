defmodule CodeCorps.GitHub.Event.Validator do
  @moduledoc ~S"""
  Default behavior for all GitHub webhook event payload validators.
  """

  @doc ~S"""
  The only entry point a GitHub webhook event validator function should contain.

  Receives the GitHub payload, returns `true` if the payload is in the expected
  format, `false` otherwise.
  """
  @callback valid?(map) :: boolean
end
