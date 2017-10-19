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
  alias GitHub.Sync.PullRequest, as: PullRequestSyncer

  @type outcome :: PullRequestSyncer.outcome
                 | {:error, :unexpected_action}
                 | {:error, :not_fully_implemented}
                 | {:error, :unexpected_payload}

  @doc ~S"""
  Handles the "PullRequest" GitHub webhook

  The process is as follows:

  - validate the payload is structured as expected
  - validate the action is properly supported
  - sync the pull request using `CodeCorps.GitHub.Sync.PullRequest`
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    with {:ok, :valid} <- validate_payload(payload),
         {:ok, :implemented} <- validate_action(payload) do
      PullRequestSyncer.sync(payload)
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec validate_payload(map) :: {:ok, :valid}
                               | {:error, :unexpected_payload}
  defp validate_payload(%{} = payload) do
    case payload |> Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :unexpected_payload}
    end
  end

  @implemented_actions ~w(opened closed edited reopened)
  @unimplemented_actions ~w(assigned unassigned review_requested review_request_removed labeled unlabeled)

  @spec validate_action(map) :: {:ok, :implemented}
                              | {:error, :not_fully_implemented }
                              | {:error, :unexpected_action}
  defp validate_action(%{"action" => action}) when action in @implemented_actions, do: {:ok, :implemented}
  defp validate_action(%{"action" => action}) when action in @unimplemented_actions, do: {:error, :not_fully_implemented}
  defp validate_action(_payload), do: {:error, :unexpected_action}
end
