defmodule CodeCorps.GitHub.Event.IssueComment.Validator do
  @moduledoc ~S"""
  In charge of validatng a GitHub IssueComment webhook payload.

  https://developer.github.com/v3/activity/events/types/#issuecommentevent
  """

  @doc ~S"""
  Returns `true` if all keys required to properly handle an Issue webhook are
  present in the provided payload.
  """
  @spec valid?(map) :: boolean
  def valid?(%{
    "action" => _,
    "issue" => %{
      "id" => _, "title" => _, "body" => _, "state" => _,
      "user" => %{"id" => _}
    },
    "comment" => %{
      "id" => _, "body" => _,
      "user" => %{"id" => _}
    },
    "repository" => %{"id" => _}}), do: true
  def valid?(_), do: false
end
