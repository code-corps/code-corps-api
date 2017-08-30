defmodule CodeCorps.GitHub.Event.Issues.ChangesetBuilder do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Task` with, when handling an
  Issues webhook.
  """

  alias CodeCorps.{
    Services.MarkdownRendererService,
    ProjectGithubRepo,
    Task,
    User
  }
  alias CodeCorps.GitHub.Adapters.Task, as: TaskAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Constructs a changeset for syncing a task when processing an Issues webhook
  """
  @spec build_changeset(Task.t, map, ProjectGithubRepo.t, User.t) :: Changeset.t
  def build_changeset(
    %Task{} = task,
    %{"issue" => issue_attrs},
    %ProjectGithubRepo{project_id: project_id},
    %User{id: user_id}) do

    task
    |> Changeset.change(issue_attrs |> TaskAdapter.from_issue())
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:project_id, project_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:project_id, :user_id, :markdown, :body, :title])
    |> Changeset.assoc_constraint(:project)
    |> Changeset.assoc_constraint(:user)
  end
end
