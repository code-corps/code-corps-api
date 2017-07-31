defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc ~S"""
  In charge of dealing with "Issues" GitHub Webhook events

  https://developer.github.com/v3/activity/events/types/#issuesevent
  """

  alias CodeCorps.{
    GithubEvent,
    GitHub.Event.Common.RepoFinder,
    GitHub.Event.Issues.TaskSyncer,
    GitHub.Event.Issues.UserLinker,
    GitHub.Event.Issues.Validator,
    Repo,
    Task
  }
  alias Ecto.Multi

  @typep outcome :: {:ok, list(Task.t)} |
                    {:error, :not_fully_implemented} |
                    {:error, :unexpected_payload} |
                    {:error, :unexpected_action} |
                    {:error, :unmatched_repository}

  @implemented_actions ~w(opened closed edited reopened)
  @unimplemented_actions ~w(assigned unassigned milestoned demilestoned labeled unlabeled)

  @doc ~S"""
  Handles the "Issues" GitHub webhook

  The process is as follows
  - validate the payload is structured as expected
  - try and find the appropriate `GithubRepo` record.
  - for each `ProjectGithubRepo` belonging to that `Project`
    - find or initialize a new `Task`
    - try and find a `User`, associate `Task` with user
    - commit the change as an insert or update action

  Depending on the success of the process, the function will return one of
  - `{:ok, list_of_tasks}`
  - `{:error, :not_fully_implemented}` - while we're aware of this action, we have not implemented support for it yet
  - `{:error, :unexpected_payload}` - the payload was not as expected
  - `{:error, :unexpected_action}` - the action was not of type we are aware of
  - `{:error, :unmatched_repository}` - the repository for this issue was not found

  Note that it is also possible to have a matched GithubRepo, but with that
  record not having any ProjectGithubRepo children. The outcome of that case
  should NOT be an errored event, since it simply means that the GithubRepo
  was not linked to a Project by the Project owner. This is allowed and
  relatively common.
  """
  @spec handle(GithubEvent.t, map) :: outcome
  def handle(%GithubEvent{action: action}, payload) when action in @implemented_actions do
    case payload |> Validator.valid? do
      true -> do_handle(payload)
      false -> {:error, :unexpected_payload}
    end
  end
  def handle(%GithubEvent{action: action}, _payload) when action in @unimplemented_actions do
    {:error, :not_fully_implemented}
  end
  def handle(%GithubEvent{action: _action}, _payload), do: {:error, :unexpected_action}

  @spec do_handle(map) :: {:ok, list(Task.t)} | {:error, :unmatched_repository}
  defp do_handle(%{"issue" => issue_payload} = payload) do
    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> RepoFinder.find_repo(payload) end)
      |> Multi.run(:user, fn _ -> UserLinker.find_or_create_user(payload) end)
      |> Multi.run(:tasks, fn %{repo: github_repo, user: user} -> TaskSyncer.sync_all(github_repo, user, payload) end)

    case Repo.transaction(multi) do
      {:ok, %{tasks: tasks}} -> {:ok, tasks}
      {:error, :repo, :unmatched_project, _steps} -> {:ok, []}
      {:error, _errored_step, error_response, _steps} -> {:error, error_response}
    end
  end
end
