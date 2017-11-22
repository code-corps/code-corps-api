defmodule CodeCorps.GitHub.Event.PullRequest do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the PullRequest event type

  [https://developer.github.com/v3/activity/events/types/#pullrequestevent](https://developer.github.com/v3/activity/events/types/#pullrequestevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub,
    GitHub.Event.PullRequest.Validator
  }
  alias GitHub.Sync

  @doc ~S"""
  Handles the "PullRequest" GitHub webhook

  The process is as follows:

  - validate the payload is structured as expected
  - validate the action is properly supported
  - sync the pull request using `CodeCorps.GitHub.Sync.PullRequest`
  """
  @impl CodeCorps.GitHub.Event.Handler
  @spec handle(map) :: {:ok, any} | {:error, atom}
  def handle(payload) do
    with {:ok, :valid} <- validate_payload(payload) do
      Sync.pull_request_event(payload)
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
