defmodule CodeCorps.GitHub.Event.PullRequest.ChangesetBuilder do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Task` with, when handling an
  PullRequest webhook.
  """

  alias CodeCorps.{
    GithubPullRequest,
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
  Constructs a changeset for syncing a `Task` when processing a PullRequest
  webhook.

  The changeset can be used to create or update a `Task`
  """
  @spec build_changeset(Task.t, map, GithubPullRequest.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  def build_changeset(
    %Task{id: task_id} = task,
    %{"pull_request" => pull_request_attrs},
    %GithubPullRequest{} = github_pull_request,
    %ProjectGithubRepo{} = project_github_repo,
    %User{} = user) do

    case is_nil(task_id) do
      true -> create_changeset(task, pull_request_attrs, github_pull_request, project_github_repo, user)
      false -> update_changeset(task, pull_request_attrs)
    end
  end

  @create_attrs ~w(created_at markdown modified_at status title)a
  @spec create_changeset(Task.t, map, GithubPullRequest.t, ProjectGithubRepo.t, User.t) :: Changeset.t
  defp create_changeset(
    %Task{} = task,
    %{} = pull_request_attrs,
    %GithubPullRequest{id: github_pull_request_id},
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %User{id: user_id}) do

    %TaskList{id: task_list_id} =
      TaskList |> Repo.get_by(project_id: project_id, inbox: true)

    task
    |> Changeset.cast(IssueAdapter.to_task(pull_request_attrs), @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_change(:github_pull_request_id, github_pull_request_id)
    |> Changeset.put_change(:github_repo_id, github_repo_id)
    |> Changeset.put_change(:project_id, project_id)
    |> Changeset.put_change(:task_list_id, task_list_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:project_id, :task_list_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_pull_request)
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:task_list)
    |> Changeset.assoc_constraint(:user)
  end

  @update_attrs ~w(markdown modified_at status title)a
  @spec update_changeset(Task.t, map) :: Changeset.t
  defp update_changeset(%Task{} = task, %{} = pull_request_attrs) do
    task
    |> Changeset.cast(IssueAdapter.to_task(pull_request_attrs), @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> TimeValidator.validate_time_after(:modified_at)
    |> Changeset.validate_required([:project_id, :title, :user_id])
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:user)
  end
end
