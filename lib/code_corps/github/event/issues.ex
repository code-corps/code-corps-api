defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the Issues event type

  [https://developer.github.com/v3/activity/events/types/#issuesevent](https://developer.github.com/v3/activity/events/types/#issuesevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub.Event.Common.RepoFinder,
    GitHub.Event.Issues.TaskSyncer,
    GitHub.Event.Issues.UserLinker,
    GitHub.Event.Issues.Validator,
    Repo,
    Task
  }
  alias Ecto.Multi

  @type outcome :: {:ok, list(Task.t)} |
                   {:error, :not_fully_implemented} |
                   {:error, :unexpected_action} |
                   {:error, :unexpected_payload} |
                   {:error, :repository_not_found} |
                   {:error, :validation_error_on_inserting_user} |
                   {:error, :multiple_github_users_matched_same_cc_user} |
                   {:error, :validation_error_on_syncing_tasks} |
                   {:error, :unexpected_transaction_outcome}

  @doc ~S"""
  Handles the "Issues" GitHub webhook

  The process is as follows
  - validate the payload is structured as expected
  - validate the action is properly supported
  - match payload with affected `CodeCorps.GithubRepo` record using `CodeCorps.GitHub.Event.Common.RepoFinder`
  - match with a `CodeCorps.User` using `CodeCorps.GitHub.Event.Issues.UserLinker`
  - for each `CodeCorps.ProjectGithubRepo` belonging to matched repo
    - match and update, or create a `CodeCorps.Task` on the associated `CodeCorps.Project`

  If the process runs all the way through, the function will return an `:ok`
  tuple with a list of affected (created or updated) tasks.

  If it fails, it will instead return an `:error` tuple, where the second
  element is the atom indicating a reason.
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    Multi.new
    |> Multi.run(:payload, fn _ -> payload |> validate_payload() end)
    |> Multi.run(:action, fn _ -> payload |> validate_action() end)
    |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
    |> Multi.run(:user, fn _ -> UserLinker.find_or_create_user(payload) end)
    |> Multi.run(:tasks, fn %{repo: github_repo, user: user} -> TaskSyncer.sync_all(github_repo, user, payload) end)
    |> Repo.transaction
    |> marshall_result()
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{tasks: tasks}}), do: {:ok, tasks}
  defp marshall_result({:error, :payload, :invalid, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :action, :not_fully_implemented, _steps}), do: {:error, :not_fully_implemented}
  defp marshall_result({:error, :action, :unexpected_action, _steps}), do: {:error, :unexpected_action}
  defp marshall_result({:error, :repo, :unmatched_project, _steps}), do: {:ok, []}
  defp marshall_result({:error, :repo, :unmatched_repository, _steps}), do: {:error, :repository_not_found}
  defp marshall_result({:error, :user, %Ecto.Changeset{}, _steps}), do: {:error, :validation_error_on_inserting_user}
  defp marshall_result({:error, :user, :multiple_users, _steps}), do: {:error, :multiple_github_users_matched_same_cc_user}
  defp marshall_result({:error, :tasks, {_tasks, _errors}, _steps}), do: {:error, :validation_error_on_syncing_tasks}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}

  @implemented_actions ~w(opened closed edited reopened)
  @unimplemented_actions ~w(assigned unassigned milestoned demilestoned labeled unlabeled)

  @spec validate_action(map) :: {:ok, :implemented} | {:error, :not_fully_implemented | :unexpected_action}
  defp validate_action(%{"action" => action}) when action in @implemented_actions, do: {:ok, :implemented}
  defp validate_action(%{"action" => action}) when action in @unimplemented_actions, do: {:error, :not_fully_implemented}
  defp validate_action(_payload), do: {:error, :unexpected_action}

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end
end
