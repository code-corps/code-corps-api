defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the Issues event type

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub,
    GitHub.Event.Issues.Validator
  }
  alias GitHub.Sync

  @type outcome :: Sync.outcome
                 | {:error, :unexpected_action}
                 | {:error, :not_fully_implemented}
                 | {:error, :unexpected_payload}

  @doc ~S"""
  Handles the "Issues" GitHub webhook

  The process is as follows:

  - validate the payload is structured as expected
  - validate the action is properly supported
  - sync the issue using `CodeCorps.GitHub.Sync.Issue`
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    with {:ok, :valid} <- validate_payload(payload),
         {:ok, :implemented} <- validate_action(payload) do
      Sync.issue_event(payload)
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
  @unimplemented_actions ~w(assigned unassigned milestoned demilestoned labeled unlabeled)

  @spec validate_action(map) :: {:ok, :implemented}
                              | {:error, :not_fully_implemented }
                              | {:error, :unexpected_action}
  defp validate_action(%{"action" => action}) when action in @implemented_actions, do: {:ok, :implemented}
  defp validate_action(%{"action" => action}) when action in @unimplemented_actions, do: {:error, :not_fully_implemented}
  defp validate_action(_payload), do: {:error, :unexpected_action}
end
