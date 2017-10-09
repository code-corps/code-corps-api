defmodule CodeCorps.GitHub.Event.IssueComment.ChangesetBuilder do
  @moduledoc ~S"""
  In charge of building a `Changeset` to update a `Comment` with, when handling
  an IssueComment webhook.
  """

  alias CodeCorps.{
    Comment,
    Services.MarkdownRendererService,
    Task,
    User
  }
  alias CodeCorps.GitHub.Adapters.Comment, as: CommentAdapter
  alias Ecto.Changeset

  @doc ~S"""
  Constructs a changeset for syncing a task when processing an IssueComment
  webhook
  """
  @spec build_changeset(Comment.t, map, Task.t, User.t) :: Changeset.t
  def build_changeset(%Comment{id: nil} = comment, %{"comment" => attrs}, %Task{} = task, %User{} = user) do
    comment |> create_changeset(attrs, task, user)
  end
  def build_changeset(%Comment{} = comment, %{"comment" => attrs}, %Task{}, %User{}) do
    comment |> update_changeset(attrs)
  end

  @create_attrs ~w(created_at github_id markdown modified_at)a
  @spec create_changeset(Comment.t, map, Task.t, User.t) :: Changeset.t
  defp create_changeset(%Comment{} = comment, %{} = attrs, %Task{} = task, %User{} = user) do
    comment
    |> Changeset.cast(CommentAdapter.from_api(attrs), @create_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:created_from, "github")
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.put_assoc(:task, task)
    |> Changeset.put_change(:user, user)
    |> Changeset.validate_required([:markdown, :body])
  end

  @update_attrs ~w(github_id markdown modified_at)a
  @spec update_changeset(Comment.t, map) :: Changeset.t
  defp update_changeset(%Comment{} = comment, %{} = attrs) do
    comment
    |> Changeset.cast(CommentAdapter.from_api(attrs), @update_attrs)
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:modified_from, "github")
    |> Changeset.validate_required([:markdown, :body])
  end
end
