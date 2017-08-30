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
  def build_changeset(
    %Comment{} = comment,
    %{"comment" => comment_attrs},
    %Task{id: task_id},
    %User{id: user_id}) do

    comment
    |> Changeset.change(comment_attrs |> CommentAdapter.from_api())
    |> MarkdownRendererService.render_markdown_to_html(:markdown, :body)
    |> Changeset.put_change(:task_id, task_id)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.validate_required([:task_id, :user_id, :markdown, :body])
    |> Changeset.assoc_constraint(:task)
    |> Changeset.assoc_constraint(:user)
  end
end
