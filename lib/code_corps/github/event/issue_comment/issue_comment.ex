defmodule CodeCorps.GitHub.Event.IssueComment do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the IssueComment event type
  [https://developer.github.com/v3/activity/events/types/#issuecommentevent](https://developer.github.com/v3/activity/events/types/#issuecommentevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub,
    GitHub.Event.IssueComment.Validator
  }
  alias GitHub.Sync

  @type outcome :: Sync.outcome | {:error, :unexpected_payload}

  @doc ~S"""
  Handles the "IssueComment" GitHub webhook

  The process is as follows:

  - validate the payload is structured as expected
  - validate the action is properly supported
  - sync the comment using `CodeCorps.GitHub.Sync.Comment`
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    with {:ok, :valid} <- validate_payload(payload) do
      Sync.issue_comment_event(payload)
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :unexpected_payload}
  defp validate_payload(%{} = payload) do
    case payload |> Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :unexpected_payload}
    end
  end
end
