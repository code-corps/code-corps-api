defmodule CodeCorps.GitHub.Event.Issues.Validator do
  @moduledoc ~S"""
  In charge of validatng a GitHub Issue webhook payload.

  https://developer.github.com/v3/activity/events/types/#issuesevent
  """

  @doc ~S"""
  Returns `true` if all keys required to properly handle an Issue webhook are
  present in the provided payload.
  """
  @spec valid?(map) :: boolean
  def valid?(%{
    "issue" => %{
      "id" => _, "title" => _, "body" => _, "state" => _,
      "user" => %{"id" => _}
    },
    "repository" => %{"id" => _}}), do: true
  def valid?(_), do: false
end
