defmodule CodeCorps.GitHub.Event.Issues.ChangesetBuilder do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Task` with, when handling an
  Issues webhook.
  """

  alias CodeCorps.{
    ProjectGithubRepo,
    Repo,
    Services.MarkdownRendererService,
    Task,
    TaskList,
    User
  }
  alias CodeCorps.GitHub.Adapters.Task, as: TaskAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Constructs a changeset for syncing a task when processing an Issues webhook
  """
  @spec build_changeset(Task.t, map, ProjectGithubRepo.t, User.t) :: Changeset.t
  def build_changeset(
    %Task{id: task_id} = task,
    %{"issue" => issue_attrs},
    %ProjectGithubRepo{} = project_github_repo,
    %User{} = user) do

    case is_nil(task_id) do
      true -> create_changeset(task, issue_attrs, project_github_repo, user)
      false -> update_changeset(task, issue_attrs)
    end
  end

  defp create_changeset(
    %Task{} = task,
    %{} = issue_attrs,
    %ProjectGithubRepo{project_id: project_id, github_repo_id: github_repo_id},
    %User{id: user_id}) do

    %TaskList{id: task_list_id} =
      TaskList |> Repo.get_by(project_id: project_id, inbox: true)

    task
    |> Changeset.change(issue_attrs |> TaskAdapter.from_issue())
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:project_id, project_id)
    |> Changeset.put_change(:task_list_id, task_list_id)
    |> Changeset.put_change(:github_repo_id, github_repo_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:project_id, :task_list_id, :user_id, :markdown, :body, :title])
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:task_list)
    |> Changeset.assoc_constraint(:user)
  end

  defp update_changeset(%Task{} = task, issue_attrs) do
    task
    |> Changeset.change(issue_attrs |> TaskAdapter.from_issue())
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.validate_required([:project_id, :user_id, :markdown, :body, :title])
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:github_repo)
    |> Changeset.assoc_constraint(:user)
  end
end
