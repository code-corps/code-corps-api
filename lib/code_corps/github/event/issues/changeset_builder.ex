defmodule CodeCorps.GitHub.Event.Issues.ChangesetBuilder do
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
  @spec build_changeset(Task.t, map, GithubIssue.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  def build_changeset(
    %Task{id: task_id} = task,
    %{"issue" => issue_attrs},
    %GithubIssue{} = github_issue,
    %ProjectGithubRepo{} = project_github_repo,
    %User{} = user) do

    case is_nil(task_id) do
      true -> create_changeset(task, issue_attrs, github_issue, project_github_repo, user)
      false -> update_changeset(task, issue_attrs)
    end
  end

  @create_attrs ~w(created_at markdown modified_at status title closed_at)a
  @spec create_changeset(Task.t, map, GithubIssue.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  defp create_changeset(
    %Task{} = task,
    %{} = issue_attrs,
    %GithubIssue{id: github_issue_id},
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %User{id: user_id}) do

    %TaskList{id: task_list_id} =
      TaskList |> Repo.get_by(project_id: project_id, inbox: true)

    task
    |> Changeset.cast(IssueAdapter.to_task(issue_attrs), @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_change(:github_issue_id, github_issue_id)
    |> Changeset.put_change(:github_repo_id, github_repo_id)
    |> Changeset.put_change(:project_id, project_id)
    |> Changeset.put_change(:task_list_id, task_list_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:project_id, :task_list_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_issue)
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:task_list)
    |> Changeset.assoc_constraint(:user)
    |> Task.order_task()
  end

  @update_attrs ~w(markdown modified_at status title closed_at)a
  @spec update_changeset(Task.t, map) :: Changeset.t
  defp update_changeset(%Task{} = task, %{} = issue_attrs) do
    task
    |> Changeset.cast(IssueAdapter.to_task(issue_attrs), @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> TimeValidator.validate_time_after(:modified_at)
    |> Changeset.validate_required([:project_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:user)
    |> Task.order_task()
  end
end
