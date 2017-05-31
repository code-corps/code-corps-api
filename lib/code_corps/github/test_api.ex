defmodule CodeCorps.GitHub.TestAPI do
  @moduledoc """
  The most basic implementation of an API module for testing. All functions
  here should return `:ok` tuples.

  If we want to test the wrapper module, we can specify custom API modules
  during function calls.
  """
  @behaviour CodeCorps.GitHub.APIContract

  @spec connect(String.t) :: {:ok, String.t}
  def connect(code), do: send(self(), {:ok, code})
end
