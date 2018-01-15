defmodule CodeCorps.GitHub.Sync.Task.Changeset do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Task` with, when handling an
  Issues webhook.
  """

  import Ecto.Query

  alias CodeCorps.{
    GithubIssue,
    GithubRepo,
    GitHub.Adapters,
    Repo,
    Services.MarkdownRendererService,
    Task,
    TaskList,
    User,
    Validators.TimeValidator
  }
  alias Ecto.Changeset


  @create_attrs ~w(created_at markdown modified_at status title)a
  @doc """
  Constructs a changeset for creating a `CodeCorps.Task` when processing an
  Issues or IssueComment webhook.
  """
  @spec create_changeset(GithubIssue.t(), GithubRepo.t(), User.t()) :: Changeset.t()
  def create_changeset(
    %GithubIssue{} = github_issue,
    %GithubRepo{project_id: project_id} = github_repo,
    %User{} = user) do

    %Task{}
    |> Changeset.cast(github_issue |> Adapters.Issue.to_task, @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_assoc(:github_issue, github_issue)
    |> Changeset.put_assoc(:github_repo, github_repo)
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_change(:project_id, project_id)
    |> Changeset.assoc_constraint(:project)
    |> assign_task_list(github_issue, github_repo)
    |> Changeset.validate_required([:project_id, :task_list_id, :title])
    |> maybe_archive()
    |> Task.handle_archived()
  end

  @update_attrs ~w(markdown modified_at status title)a
  @doc """
  Constructs a changeset for updating a `CodeCorps.Task` when processing an
  Issues or IssueComment webhook.
  """
  @spec update_changeset(Task.t(), GithubIssue.t(), GithubRepo.t()) :: Changeset.t()
  def update_changeset(
    %Task{} = task,
    %GithubIssue{} = github_issue,
    %GithubRepo{} = github_repo) do

    task
    |> Changeset.cast(github_issue |> Adapters.Issue.to_task, @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> TimeValidator.validate_time_not_before(:modified_at)
    |> assign_task_list(github_issue, github_repo)
    |> Changeset.validate_required([:title])
    |> maybe_archive()
    |> Task.handle_archived()
  end

  @spec assign_task_list(Changeset.t(), GithubIssue.t(), GithubRepo.t()) :: Changeset.t()
  defp assign_task_list(
    %Changeset{} = changeset,
    %GithubIssue{} = issue,
    %GithubRepo{project_id: project_id}) do

    list_type = issue |> get_task_list_type()

    %TaskList{id: id} =
      TaskList
      |> where(project_id: ^project_id)
      |> where([t], field(t, ^list_type) == true)
      |> Repo.one()

    # put_change/2 instead of put_assoc/2 so task list
    # doesn't have to be preloaded
    changeset
    |> Changeset.put_change(:task_list_id, id)
    |> Changeset.assoc_constraint(:task_list)
  end

  @spec get_task_list_type(GithubIssue.t()) :: atom
  defp get_task_list_type(%GithubIssue{state: "closed"}), do: :done
  defp get_task_list_type(%GithubIssue{state: "open", github_pull_request_id: id})
    when not is_nil(id), do: :pull_requests
  defp get_task_list_type(%GithubIssue{state: "open"}), do: :inbox

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
