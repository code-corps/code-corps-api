defmodule CodeCorps.GitHub.Event.Issues.StateMapper do
  @moduledoc ~S"""
  In charge of inferring a `Task` `:state` from a GitHub payload
  """

  @doc ~S"""
  From the provided GitHub Issue webhook payload, determins the appropriate
  state for a `Task` to be put in.
  """
  @spec get_state(map) :: String.t
  def get_state(%{"action" => "opened"}), do: "published"
  def get_state(%{"action" => "closed"}), do: "edited"
  def get_state(%{"action" => "edited"}), do: "edited"
  def get_state(%{"action" => "reopened"}), do: "edited"
end
