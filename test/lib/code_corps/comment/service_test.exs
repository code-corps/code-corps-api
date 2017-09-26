defmodule CodeCorps.Comment.ServiceTest do
  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.Comment

  @base_attrs %{"markdown" => "A test task"}

  defp valid_attrs() do
    user = insert(:user)
    task = insert(:task)

    @base_attrs
    |> Map.put("user_id", user.id)
    |> Map.put("task_id", task.id)
  end

  describe "create/2" do
    test "creates comment" do
      {:ok, comment} = valid_attrs() |> Comment.Service.create

      assert comment.markdown == @base_attrs["markdown"]
      assert comment.body
      refute comment.github_id

      refute_received({:post, _string, {}, "{}", []})
    end

    test "returns errored changeset if attributes are invalid" do
      {:error, changeset} = Comment.Service.create(@base_attrs)
      refute changeset.valid?
      refute Repo.one(Comment)

      refute_received({:post, _string, _headers, _body, _options})
    end

    test "if comment is assigned a github repo, creates github comment on assigned issue" do
      user = insert(:user)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      task = insert(:task, github_repo: github_repo, github_issue_number: 5)

      {:ok, comment} =
        @base_attrs
        |> Map.put("task_id", task.id)
        |> Map.put("user_id", user.id)
        |> Comment.Service.create

      assert comment.markdown == @base_attrs["markdown"]
      assert comment.body
      assert comment.github_id

      assert_received({:post, "https://api.github.com/repos/foo/bar/issues/5/comments", _headers, _body, _options})
    end

    test "if github process fails, returns {:error, :github}" do
      user = insert(:user)
      github_repo = insert(:github_repo, github_account_login: "foo", name: "bar")
      task = insert(:task, github_repo: github_repo, github_issue_number: 5)

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :github} ==
          @base_attrs
          |> Map.put("task_id", task.id)
          |> Map.put("user_id", user.id)
          |> Comment.Service.create
      end

      refute Repo.one(Comment)
      assert_received({:post, "https://api.github.com/repos/foo/bar/issues/5/comments", _headers, _body, _options})
    end
  end

  describe "update/2" do
    @update_attrs %{"markdown" => "bar"}

    test "updates comment" do
      comment = insert(:comment)
      {:ok, updated_comment} = comment |> Comment.Service.update(@update_attrs)

      assert updated_comment.id == comment.id
      assert updated_comment.markdown == @update_attrs["markdown"]
      assert updated_comment.body != comment.body
      refute updated_comment.github_id

      refute_received({:post, _string, {}, "{}", []})
    end

    test "propagates changes to github if comment is synced to github comment" do
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      task = insert(:task, github_repo: github_repo, github_issue_number: 5)
      comment = insert(:comment, github_id: 6, task: task)

      {:ok, updated_comment} = comment |> Comment.Service.update(@update_attrs)

      assert updated_comment.id == comment.id
      assert updated_comment.markdown == @update_attrs["markdown"]
      assert updated_comment.body != comment.body
      assert updated_comment.github_id

      assert_received({:patch, "https://api.github.com/repos/foo/bar/issues/comments/6", _headers, _body, _options})
    end

    test "reports {:error, :github}, makes no changes at all if there is a github api error" do
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      task = insert(:task, github_repo: github_repo, github_issue_number: 5)
      comment = insert(:comment, github_id: 6, task: task)

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :github} == comment |> Comment.Service.update(@update_attrs)
      end

      updated_comment = Repo.one(Comment)

      assert updated_comment.id == comment.id
      assert updated_comment.markdown == comment.markdown
      assert updated_comment.body == comment.body
      assert updated_comment.github_id == comment.github_id

      assert_received({:patch, "https://api.github.com/repos/foo/bar/issues/comments/6", _headers, _body, _options})
    end
  end
end
