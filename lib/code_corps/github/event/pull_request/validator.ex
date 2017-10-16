defmodule CodeCorps.GitHub.Event.PullRequest.Validator do
  @moduledoc ~S"""
  In charge of validatng a GitHub PullRequest webhook payload.

  https://developer.github.com/v3/activity/events/types/#pullrequestevent
  """

  @doc ~S"""
  Returns `true` if all keys required to properly handle an PullRequest webhook
  are present in the provided payload.
  """
  @spec valid?(map) :: boolean
  def valid?(%{
    "action" => _,
    "pull_request" => %{
      "id" => _,
      "title" => _,
      "user" => %{
        "id" => _
      }
    },
    "repository" => %{
      "id" => _
    }
  }), do: true
  def valid?(_), do: false
end
