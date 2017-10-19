defmodule CodeCorps.GitHub.Event.IssueCommentTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{
    Comment,
    GithubComment,
    GithubIssue,
    GitHub.Event.IssueComment,
    Project,
    Task,
    Repo,
    User
  }

  describe "handle/1" do
    @payload load_event_fixture("issue_comment_created") |> Map.put("action", "foo")

    test "returns error if action of the event is wrong" do
      assert {:error, :unexpected_action} == IssueComment.handle(@payload)
    end
  end

  for action <- ["created", "edited"] do
    describe "handle/1 for IssueComment::#{action}" do
      @payload load_event_fixture("issue_comment_#{action}")

      test "with unmatched both users, creates users, creates missing tasks, missing comments, for all projects connected with the github repo" do
        %{
          "issue" => %{
            "body" => issue_markdown, "title" => issue_title, "number" => issue_number, "state" => issue_state,
            "user" => %{"id" => issue_user_github_id}
          },
          "comment" => %{
            "body" => comment_markdown, "id" => comment_github_id,
            "user" => %{"id" => comment_user_github_id}
          },
          "repository" => %{"id" => repo_github_id}
        } = @payload

        github_repo = insert(:github_repo, github_id: repo_github_id)

        project_ids =
          insert_list(3, :project_github_repo, github_repo: github_repo)
          |> Enum.map(&Map.get(&1, :project_id))

        project_ids |> Enum.each(fn project_id ->
          project = Project |> Repo.get_by(id: project_id)
          insert(:task_list, project: project, inbox: true)
        end)

        {:ok, comments} = IssueComment.handle(@payload)

        assert Enum.count(comments) == 3
        assert Repo.aggregate(Task, :count, :id) == 3
        assert Repo.aggregate(Comment, :count, :id) == 3

        issue_user = Repo.get_by(User, github_id: issue_user_github_id)

        Repo.all(Task) |> Enum.each(fn task ->
          assert task.project_id in project_ids
          assert task.user_id == issue_user.id
          assert task.github_repo_id == github_repo.id
        end)

        Repo.all(GithubIssue) |> Enum.each(fn github_issue ->
          assert github_issue.number == issue_number
          assert github_issue.body == issue_markdown
          assert github_issue.state == issue_state
          assert github_issue.title == issue_title
        end)

        comment_user = Repo.get_by(User, github_id: comment_user_github_id)

        comments |> Enum.each(fn comment ->
          assert comment.body
          assert comment.markdown == comment_markdown
          assert comment.user_id == comment_user.id
        end)

        Repo.all(GithubComment) |> Enum.each(fn github_comment ->
          assert github_comment.github_id == comment_github_id
          assert github_comment.body == comment_markdown
        end)

        assert Repo.aggregate(GithubComment, :count, :id) == 1
      end

      test "with unmatched both users, returns error if unmatched repository" do
        assert IssueComment.handle(@payload) == {:error, :repository_not_found}
        refute Repo.one(User)
      end

      test "with matched issue user, unmatched comment user, creates and updates tasks, comments and comment user, for each related project" do
        %{
          "issue" => %{
            "id" => issue_github_id,
            "body" => issue_markdown, "title" => issue_title, "number" => issue_number, "state" => issue_state,
            "user" => %{"id" => issue_user_github_id}
          },
          "comment" => %{
            "body" => comment_markdown, "id" => comment_github_id,
            "user" => %{"id" => comment_user_github_id}
          },
          "repository" => %{"id" => repo_github_id}
        } = @payload

        issue_user = insert(:user, github_id: issue_user_github_id)
        github_repo = insert(:github_repo, github_id: repo_github_id)

        [%{project: project_1}, %{project: _project_2}, %{project: _project_3}] =
          project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

        project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

        project_ids |> Enum.each(fn project_id ->
          project = Project |> Repo.get_by(id: project_id)
          insert(:task_list, project: project, inbox: true)
        end)

        github_issue = insert(:github_issue, github_repo: github_repo, number: issue_number, github_id: issue_github_id)

        # there's a task for project 1
        task_1 = insert(:task, project: project_1, user: issue_user, github_repo: github_repo, github_issue: github_issue)

        {:ok, comments} = IssueComment.handle(@payload)

        assert Enum.count(comments) == 3
        assert Repo.aggregate(Task, :count, :id) == 3
        assert Repo.aggregate(Comment, :count, :id) == 3

        tasks = Repo.all(Task)

        tasks |> Enum.each(fn task ->
          assert task.project_id in project_ids
          assert task.user_id == issue_user.id
          assert task.github_repo_id == github_repo.id
        end)

        Repo.all(GithubIssue) |> Enum.each(fn github_issue ->
          assert github_issue.number == issue_number
          assert github_issue.body == issue_markdown
          assert github_issue.state == issue_state
          assert github_issue.title == issue_title
        end)

        task_ids = tasks |> Enum.map(&Map.get(&1, :id))
        assert task_1.id in task_ids

        comment_user = Repo.get_by(User, github_id: comment_user_github_id)

        comments |> Enum.each(fn comment ->
          assert comment.body
          assert comment.markdown == comment_markdown
          assert comment.user_id == comment_user.id
        end)

        Repo.all(GithubComment) |> Enum.each(fn github_comment ->
          assert github_comment.github_id == comment_github_id
          assert github_comment.body == comment_markdown
        end)

        assert Repo.aggregate(GithubComment, :count, :id) == 1
      end

      test "with matched issue user, unmatched comment user, returns error if unmatched repository" do
        %{"issue" => %{"user" => %{"id" => issue_user_github_id}}} = @payload

        _issue_user = insert(:user, github_id: issue_user_github_id)

        assert IssueComment.handle(@payload) == {:error, :repository_not_found}
      end

      test "with unmatched issue user, matched comment user, creates and updates tasks, comments and issue user, for each related project" do
        %{
          "issue" => %{
            "body" => issue_markdown, "title" => issue_title, "number" => issue_number, "state" => issue_state,
            "user" => %{"id" => issue_user_github_id}
          },
          "comment" => %{
            "body" => comment_markdown, "id" => comment_github_id,
            "user" => %{"id" => comment_user_github_id}
          },
          "repository" => %{"id" => repo_github_id}
        } = @payload

        comment_user = insert(:user, github_id: comment_user_github_id)
        github_repo = insert(:github_repo, github_id: repo_github_id)

        [%{project: _project_1}, %{project: _project_2}, %{project: _project_3}] =
          project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

        project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

        project_ids |> Enum.each(fn project_id ->
          project = Project |> Repo.get_by(id: project_id)
          insert(:task_list, project: project, inbox: true)
        end)

        {:ok, comments} = IssueComment.handle(@payload)

        assert Enum.count(comments) == 3
        assert Repo.aggregate(Task, :count, :id) == 3
        assert Repo.aggregate(Comment, :count, :id) == 3

        issue_user = Repo.get_by(User, github_id: issue_user_github_id)

        Repo.all(Task) |> Enum.each(fn task ->
          assert task.project_id in project_ids
          assert task.user_id == issue_user.id
          assert task.github_repo_id == github_repo.id
        end)

        Repo.all(GithubIssue) |> Enum.each(fn github_issue ->
          assert github_issue.number == issue_number
          assert github_issue.body == issue_markdown
          assert github_issue.state == issue_state
          assert github_issue.title == issue_title
        end)

        comments |> Enum.each(fn comment ->
          assert comment.body
          assert comment.markdown == comment_markdown
          assert comment.user_id == comment_user.id
        end)

        Repo.all(GithubComment) |> Enum.each(fn github_comment ->
          assert github_comment.github_id == comment_github_id
          assert github_comment.body == comment_markdown
        end)

        assert Repo.aggregate(GithubComment, :count, :id) == 1
      end

      test "with unmatched issue user, matched comment user, returns error if unmatched repository" do
        %{"comment" => %{"user" => %{"id" => comment_user_github_id}}} = @payload

        _comment_user = insert(:user, github_id: comment_user_github_id)

        assert IssueComment.handle(@payload) == {:error, :repository_not_found}
      end

      test "with matched issue and comment user, creates and updates tasks, comments, for each related project" do
        %{
          "issue" => %{
            "id" => issue_github_id,
            "body" => issue_markdown, "title" => issue_title, "number" => issue_number, "state" => issue_state,
            "user" => %{"id" => user_github_id}
          },
          "comment" => %{
            "body" => comment_markdown, "id" => comment_github_id,
            "user" => _same_as_issue_user_payload
          },
          "repository" => %{"id" => repo_github_id}
        } = @payload

        user = insert(:user, github_id: user_github_id)
        github_repo = insert(:github_repo, github_id: repo_github_id)

        [%{project: project_1}, %{project: project_2}, %{project: _project_3}] =
          project_github_repos = insert_list(3, :project_github_repo, github_repo: github_repo)

        project_ids = project_github_repos |> Enum.map(&Map.get(&1, :project_id))

        project_ids |> Enum.each(fn project_id ->
          project = Project |> Repo.get_by(id: project_id)
          insert(:task_list, project: project, inbox: true)
        end)

        github_issue = insert(:github_issue, github_repo: github_repo, number: issue_number, github_id: issue_github_id)
        github_comment = insert(:github_comment, github_issue: github_issue, github_id: comment_github_id)

        # there's a task and comment for project 1
        task_1 = insert(:task, project: project_1, user: user, github_repo: github_repo, github_issue: github_issue)
        comment_1 = insert(:comment, task: task_1, user: user, github_comment: github_comment)

        # there is only a task for project 2
        task_2 = insert(:task, project: project_2, user: user, github_repo: github_repo, github_issue: github_issue)

        {:ok, comments} = IssueComment.handle(@payload)

        assert Enum.count(comments) == 3
        assert Repo.aggregate(Task, :count, :id) == 3
        assert Repo.aggregate(Comment, :count, :id) == 3

        tasks = Repo.all(Task)

        tasks |> Enum.each(fn task ->
          assert task.project_id in project_ids
          assert task.user_id == user.id
          assert task.github_repo_id == github_repo.id
        end)

        task_ids = tasks |> Enum.map(&Map.get(&1, :id))

        assert task_1.id in task_ids
        assert task_2.id in task_ids

        Repo.all(GithubIssue) |> Enum.each(fn github_issue ->
          assert github_issue.number == issue_number
          assert github_issue.body == issue_markdown
          assert github_issue.state == issue_state
          assert github_issue.title == issue_title
        end)

        comments |> Enum.each(fn comment ->
          assert comment.body
          assert comment.markdown == comment_markdown
          assert comment.user_id == user.id
        end)

        comment_ids = comments |> Enum.map(&Map.get(&1, :id))
        assert comment_1.id in comment_ids

        Repo.all(GithubComment) |> Enum.each(fn github_comment ->
          assert github_comment.github_id == comment_github_id
          assert github_comment.body == comment_markdown
        end)

        assert Repo.aggregate(GithubComment, :count, :id) == 1
      end

      test "with matched issue and comment user, returns error if unmatched repository" do
        %{
          "issue" => %{"user" => %{"id" => issue_user_github_id}},
          "comment" => %{"user" => %{"id" => comment_user_github_id}},
          "repository" => %{"id" => _repo_github_id}
        } = @payload

        insert(:user, github_id: comment_user_github_id)
        insert(:user, github_id: issue_user_github_id)

        assert IssueComment.handle(@payload) == {:error, :repository_not_found}
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

    test "deletes all comments with github_id specified in the payload" do
      %{"comment" => %{"id" => github_id}} = @payload
      github_comment_1 = insert(:github_comment, github_id: github_id)
      github_comment_2 = insert(:github_comment)

      insert_list(3, :comment, github_comment: github_comment_1)
      insert_list(2, :comment)
      insert_list(4, :comment, github_comment: github_comment_2)

      {:ok, comments} = IssueComment.handle(@payload)
      assert Enum.count(comments) == 3
      assert Repo.aggregate(Comment, :count, :id) == 6
    end
  end
end
