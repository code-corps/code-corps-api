defmodule CodeCorps.GitHub.Event.IssueCommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Comment,
    GithubComment,
    GithubIssue,
    GitHub.Event.IssueComment,
    Task,
    Repo,
    User
  }

  for action <- ["created", "edited"] do
    describe "handle/1 for IssueComment::#{action}" do
      @payload load_event_fixture("issue_comment_#{action}")

      test "creates or updates associated records" do
        %{"repository" => %{"id" => repo_github_id}} = @payload

        project = insert(:project)
        insert(:github_repo, github_id: repo_github_id, project: project)
        insert(:task_list, project: project, inbox: true)

        {:ok, %Comment{}} = IssueComment.handle(@payload)

        assert Repo.aggregate(Comment, :count, :id) == 1
        assert Repo.aggregate(GithubComment, :count, :id) == 1
        assert Repo.aggregate(GithubIssue, :count, :id) == 1
        assert Repo.aggregate(Task, :count, :id) == 1
      end

      test "returns error if unmatched repository" do
        assert IssueComment.handle(@payload) == {:error, :repo_not_found, %{}}
        refute Repo.one(User)
      end

      test "returns error if payload is wrong" do
        assert {:error, :unexpected_payload} == IssueComment.handle(%{})
      end

      test "returns error if repo payload is wrong" do
        assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("repository", "foo"))
      end

      test "returns error if issue payload is wrong" do
        assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("issue", "foo"))
      end

      test "returns error if comment payload is wrong" do
        assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("comment", "foo"))
      end
    end
  end

  describe "handle/1 for IssueComment::deleted" do
    @payload load_event_fixture("issue_comment_deleted")

    test "deletes all comments related to and github comment with github_id specified in the payload" do
      %{"comment" => %{"id" => github_id}} = @payload
      github_repo = insert(:github_repo)
      github_issue = insert(:github_issue, github_repo: github_repo)
      github_comment = insert(:github_comment, github_id: github_id, github_issue: github_issue)
      comment = insert(:comment, github_comment: github_comment)

      {:ok, results} = IssueComment.handle(@payload)
      %{
        deleted_comments: [deleted_comment],
        deleted_github_comment: deleted_github_comment
      } = results


      assert github_comment.id == deleted_github_comment.id
      assert comment.id == deleted_comment.id
      assert Repo.aggregate(Comment, :count, :id) == 0
      assert Repo.aggregate(GithubComment, :count, :id) == 0
    end

    test "returns error if payload is wrong" do
      assert {:error, :unexpected_payload} == IssueComment.handle(%{})
    end

    test "returns error if repo payload is wrong" do
      assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("repository", "foo"))
    end

    test "returns error if issue payload is wrong" do
      assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("issue", "foo"))
    end

    test "returns error if comment payload is wrong" do
      assert {:error, :unexpected_payload} == IssueComment.handle(@payload |> Map.put("comment", "foo"))
    end
  end
end
