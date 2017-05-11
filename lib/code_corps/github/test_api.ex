defmodule CodeCorps.Github.TestAPI do
  @moduledoc """
  The most basic implementation of an API module for testing. All functions
  here should return successes.

  If we want to test the wrapper module, we can specify custom API modules
  during function calls.
  """
  @behaviour CodeCorps.Github.APIContract

  @spec connect(String.t) :: {:ok, String.t}
  def connect(code), do: send(self(), {:ok, code})
end
