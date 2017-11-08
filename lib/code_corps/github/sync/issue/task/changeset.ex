defmodule CodeCorps.GitHub.Sync.Issue.Task.Changeset do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Task` with, when handling an
  Issues webhook.
  """

  alias CodeCorps.{
    GithubIssue,
    ProjectGithubRepo,
    Repo,
    Services.MarkdownRendererService,
    Task,
    TaskList,
    User,
    Validators.TimeValidator
  }
  alias CodeCorps.GitHub.Adapters.Issue, as: IssueAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Constructs a changeset for syncing a `Task` when processing an Issues or
  IssueComment webhook.

  The changeset can be used to create or update a `Task`
  """
  @spec build_changeset(Task.t, GithubIssue.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  def build_changeset(
    %Task{id: task_id} = task,
    %GithubIssue{} = github_issue,
    %ProjectGithubRepo{} = project_github_repo,
    %User{} = user) do

    case is_nil(task_id) do
      true -> create_changeset(task, github_issue, project_github_repo, user)
      false -> update_changeset(task, github_issue, project_github_repo)
    end
  end

  @create_attrs ~w(created_at markdown modified_at status title)a
  @spec create_changeset(Task.t, GithubIssue.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  defp create_changeset(
    %Task{} = task,
    %GithubIssue{id: github_issue_id} = github_issue,
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %User{id: user_id}) do

    task
    |> Changeset.cast(github_issue |> IssueAdapter.to_task, @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_change(:github_issue_id, github_issue_id)
    |> Changeset.put_change(:github_repo_id, github_repo_id)
    |> Changeset.put_change(:project_id, project_id)
    |> assign_task_list(github_issue, project_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:project_id, :task_list_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_issue)
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:user)
    |> maybe_archive()
    |> Task.handle_archived()
  end

  @update_attrs ~w(markdown modified_at status title)a
  @spec update_changeset(Task.t, GithubIssue.t, ProjectGithubRepo.t) :: Changeset.t
  defp update_changeset(
    %Task{} = task,
    %GithubIssue{} = github_issue,
    %ProjectGithubRepo{project_id: project_id}) do
    task
    |> Changeset.cast(github_issue |> IssueAdapter.to_task, @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> TimeValidator.validate_time_not_before(:modified_at)
    |> assign_task_list(github_issue, project_id)
    |> Changeset.validate_required([:project_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:user)
    |> maybe_archive()
    |> Task.handle_archived()
  end

  @spec assign_task_list(Changeset.t, GithubIssue.t, integer) :: Changeset.t
  defp assign_task_list(
    %Changeset{} = changeset, %GithubIssue{} = github_issue, project_id)
  do
    %TaskList{id: task_list_id} =
      github_issue
      |> get_task_list_type()
      |> get_task_list(project_id)

    changeset
    |> Changeset.put_change(:task_list_id, task_list_id)
    |> Changeset.assoc_constraint(:task_list)
  end

  @spec get_task_list_type(GithubIssue.t) :: atom
  defp get_task_list_type(%GithubIssue{state: "closed"}), do: :done
  defp get_task_list_type(%GithubIssue{state: "open", github_pull_request_id: pr_id})
    when not is_nil(pr_id), do: :pull_requests
  defp get_task_list_type(%GithubIssue{state: "open"}), do: :inbox

  @spec get_task_list(atom, integer) :: TaskList.t
  defp get_task_list(:done, project_id) do
    TaskList |> Repo.get_by(project_id: project_id, done: true)
  end
  defp get_task_list(:inbox, project_id) do
    TaskList |> Repo.get_by(project_id: project_id, inbox: true)
  end
  defp get_task_list(:pull_requests, project_id) do
    TaskList |> Repo.get_by(project_id: project_id, pull_requests: true)
  end

  @spec maybe_archive(Changeset.t) :: Changeset.t
  defp maybe_archive(%Changeset{} = changeset) do
    modified_at = changeset |> Changeset.get_field(:modified_at)
    status = changeset |> Changeset.get_field(:status)

    case {status, Timex.now |> Timex.diff(modified_at, :days)} do
      {"closed", days_since_modified} when days_since_modified > 30 ->
        changeset |> Changeset.put_change(:archived, true)
      _ -> changeset
    end
  end
end
