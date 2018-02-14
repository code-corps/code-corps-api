defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the Issues event type

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub.Sync,
    GitHub.Event.Issues.Validator
  }

  @doc ~S"""
  Handles the "Issues" GitHub webhook

  The process is as follows:

  - validate the payload is structured as expected
  - validate the action is properly supported
  - sync the issue using `CodeCorps.GitHub.Sync.Issue`
  """
  @impl CodeCorps.GitHub.Event.Handler
  @spec handle(map) ::
    Sync.issue_event_outcome() | {:error, :unexpected_payload}
  def handle(payload) do
    with {:ok, :valid} <- validate_payload(payload) do
      Sync.issue_event(payload)
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :unexpected_payload}
  defp validate_payload(%{} = payload) do
    if Validator.valid?(payload) do
      {:ok, :valid}
    else
      {:error, :unexpected_payload}
    end
  end
end
