defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc ~S"""
  In charge of dealing with "Issues" GitHub Webhook events

  https://developer.github.com/v3/activity/events/types/#issuesevent
  """

  alias CodeCorps.{
    GithubEvent,
    GithubRepo,
    GitHub.Event.Issues.ChangesetBuilder,
    GitHub.Event.Issues.Validator,
    GitHub.Event.Issues.UserLinker,
    ProjectGithubRepo,
    Repo,
    Task,
    User
  }
  alias Ecto.{Changeset, Multi}

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
  defp do_handle(%{} = payload) do
    multi =
      Multi.new
      |> Multi.run(:repo, fn _ -> find_repo(payload) end)
      |> Multi.run(:user, fn _ -> UserLinker.find_or_create_user(payload) end)
      |> Multi.run(:tasks, &sync_all(&1, payload))

    case Repo.transaction(multi) do
      {:ok, %{tasks: tasks}} -> {:ok, tasks}
      {:error, :repo, :unmatched_project, _steps} -> {:ok, []}
      {:error, _errored_step, error_response, _steps} -> {:error, error_response}
    end
  end

  @spec find_repo(map) :: {:ok, GithubRepo.t} | {:error, :unmatched_repository} | {:error, :unmatched_project}
  defp find_repo(%{"repository" => %{"id" => github_id}}) do
    case GithubRepo |> Repo.get_by(github_id: github_id) |> Repo.preload(:project_github_repos) do
      # a GithubRepo with at least some ProjectGithubRepo children
      %GithubRepo{project_github_repos: [_ | _]} = github_repo -> {:ok, github_repo}
      # a GithubRepo with no ProjectGithubRepo children
      %GithubRepo{project_github_repos: []} -> {:error, :unmatched_project}
      nil -> {:error, :unmatched_repository}
    end
  end

  @spec sync_all(map, map) :: {:ok, list(Task.t)}
  defp sync_all(
    %{
      repo: %GithubRepo{project_github_repos: project_github_repos},
      user: %User{} = user
    },
    %{} = payload) do

    project_github_repos
    |> Enum.map(&sync(&1, user, payload))
    |> aggregate()
  end

  @spec sync(ProjectGithubRepo.t, User.t, map) :: {:ok, ProjectGithubRepo.t} | {:error, Changeset.t}
  defp sync(%ProjectGithubRepo{} = project_github_repo, %User{} = user, %{} = payload) do
    project_github_repo
    |> find_or_init_task(payload)
    |> ChangesetBuilder.build_changeset(payload, project_github_repo, user)
    |> commit()
  end

  @spec find_or_init_task(ProjectGithubRepo.t, map) :: Task.t
  defp find_or_init_task(%ProjectGithubRepo{project_id: project_id}, %{"issue" => %{"id" => github_id}}) do
    case Task |> Repo.get_by(github_id: github_id, project_id: project_id) do
      nil -> %Task{}
      %Task{} = task -> task
    end
  end

  @spec commit(Changeset.t) :: {:ok, Task.t} | {:error, Changeset.t}
  defp commit(%Changeset{data: %Task{id: nil}} = changeset), do: changeset |> Repo.insert
  defp commit(%Changeset{} = changeset), do: changeset |> Repo.update

  @spec aggregate(list({:ok, Task.t})) :: {:ok, list(Task.t)}
  defp aggregate(results) do
    results
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&List.last/1)
    |> (fn tasks -> {:ok, tasks} end).()
  end
end
