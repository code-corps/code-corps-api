defmodule CodeCorps.GitHub.Sync.Comment.Comment.Changeset do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Comment` with, when handling
  a GitHub Comment payload.
  """

  alias CodeCorps.{
    Comment,
    GithubComment,
    Services.MarkdownRendererService,
    Task,
    User,
    Validators.TimeValidator
  }
  alias CodeCorps.GitHub.Adapters.Comment, as: CommentAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Constructs a changeset for syncing a task when processing a GitHub Comment
  payload
  """
  @spec build_changeset(Comment.t, map, GithubComment.t, Task.t, User.t) :: Changeset.t
  def build_changeset(
    %Comment{id: nil} = comment,
    %{} = attrs,
    %GithubComment{} = github_comment,
    %Task{} = task,
    %User{} = user) do

    comment |> create_changeset(attrs, github_comment, task, user)
  end
  def build_changeset(%Comment{} = comment, attrs, %GithubComment{}, %Task{}, %User{}) do
    comment |> update_changeset(attrs)
  end

  @create_attrs ~w(created_at markdown modified_at)a
  @spec create_changeset(Comment.t, map, GithubComment.t, Task.t, User.t) :: Changeset.t
  defp create_changeset(
    %Comment{} = comment,
    %{} = attrs,
    %GithubComment{} = github_comment,
    %Task{} = task,
    %User{} = user) do

    comment
    |> Changeset.cast(CommentAdapter.to_comment(attrs), @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_assoc(:task, task)
    |> Changeset.put_assoc(:github_comment, github_comment)
    |> Changeset.put_change(:user, user)
    |> Changeset.validate_required([:markdown, :body])
  end

  @update_attrs ~w(markdown modified_at)a
  @spec update_changeset(Comment.t, map) :: Changeset.t
  defp update_changeset(%Comment{} = comment, %{} = attrs) do
    comment
    |> Changeset.cast(CommentAdapter.to_comment(attrs), @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> TimeValidator.validate_time_after(:modified_at)
    |> Changeset.validate_required([:markdown, :body])
  end
end
