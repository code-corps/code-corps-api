defmodule CodeCorps.GitHub.Event.IssueComment.CommentDeleterTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    GitHub.Event.IssueComment.CommentDeleter,
    Repo,
    Comment
  }

  describe "delete_all/1" do
    @payload load_event_fixture("issue_comment_deleted")

    test "deletes all comments with github id specified in the payload" do
      %{"comment" => %{"id" => comment_github_id}} = @payload

      github_comment = insert(:github_comment, github_id: comment_github_id)
      github_comment_2 = insert(:github_comment)

      insert_list(2, :comment, github_comment: github_comment)
      insert_list(3, :comment, github_comment: nil)
      insert_list(1, :comment, github_comment: github_comment_2)

      {:ok, deleted_comments} = CommentDeleter.delete_all(@payload)

      assert Enum.count(deleted_comments) == 2
      assert Repo.aggregate(Comment, :count, :id) == 4
    end
  end
end
