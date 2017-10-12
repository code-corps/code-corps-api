defmodule CodeCorps.GitHub.Event.Handler do
  @moduledoc ~S"""
  Default behavior for all GitHub webhook event handlers.
  """

  @doc ~S"""
  The only entry point a GitHub webhook event handler function should contain.

  Receives the GitHub payload, returns an `:ok` tuple if the process was
  successful, or an `:error` tuple, where the second element is an atom, if it
  failed.
  """
  @callback handle(map) :: {:ok, any} | {:error, atom}
end
