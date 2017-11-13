defmodule CodeCorps.GitHub.Sync.Comment.Comment.Changeset do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Comment` with, when handling
  a GitHub Comment payload.
  """

  alias CodeCorps.{
    Comment,
    GithubComment,
    GitHub.Adapters,
    Services.MarkdownRendererService,
    Task,
    User
  }
  alias Ecto.Changeset

  @create_attrs ~w(created_at markdown modified_at)a
  @update_attrs ~w(markdown modified_at)a
  @doc ~S"""
  Constructs a changeset for syncing a task from a `GithubComment` record.
  """
  @spec build_changeset(Comment.t, GithubComment.t, Task.t, User.t) :: Changeset.t
  def build_changeset(
    %Comment{id: nil} = comment,
    %GithubComment{} = github_comment,
    %Task{} = task,
    %User{} = user) do

    comment
    |> Changeset.cast(github_comment |> Adapters.Comment.to_comment, @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_assoc(:task, task)
    |> Changeset.put_assoc(:github_comment, github_comment)
    |> Changeset.put_change(:user, user)
    |> Changeset.validate_required([:markdown, :body])
  end
  def build_changeset(
    %Comment{} = comment,
    %GithubComment{} = github_comment,
    %Task{} = _task,
    %User{} = _user) do

    comment
    |> Changeset.cast(github_comment |> Adapters.Comment.to_comment, @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.validate_required([:markdown, :body])
  end
end
