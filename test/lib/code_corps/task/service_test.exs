defmodule CodeCorps.Task.ServiceTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.Task

  @base_attrs %{
    "title" => "Test task",
    "markdown" => "A test task",
    "status" => "open"
  }

  defp valid_attrs() do
    project = insert(:project)
    task_list = insert(:task_list, project: project, inbox: true)
    user = insert(:user)

    @base_attrs
    |> Map.put("project_id", project.id)
    |> Map.put("task_list_id", task_list.id)
    |> Map.put("user_id", user.id)
  end

  describe "create/2" do
    test "creates task" do
      {:ok, task} = valid_attrs() |> Task.Service.create

      assert task.title == @base_attrs["title"]
      assert task.markdown == @base_attrs["markdown"]
      assert task.body
      assert task.status == "open"
      refute task.github_issue_id
      refute task.github_repo_id

      refute_received({:post, "https://api.github.com/" <> _rest, _body, _headers, _options})
    end

    test "sets modified_from to 'code_corps'" do
      {:ok, task} = valid_attrs() |> Task.Service.create
      assert task.modified_from == "code_corps"
    end

    test "returns errored changeset if attributes are invalid" do
      {:error, changeset} = Task.Service.create(@base_attrs)
      refute changeset.valid?
      refute Repo.one(Task)

      refute_received({:post, "https://api.github.com/" <> _rest, _body, _headers, _options})
    end

    test "if task is assigned a github repo, creates github issue on assigned repo" do
      attrs = valid_attrs()
      project = Repo.one(CodeCorps.Project)
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      insert(:project_github_repo, project: project, github_repo: github_repo)

      {:ok, task} =
        attrs
        |> Map.put("github_repo_id", github_repo.id)
        |> Task.Service.create

      assert task.title == @base_attrs["title"]
      assert task.markdown == @base_attrs["markdown"]
      assert task.body
      assert task.status == "open"
      assert task.github_issue_id
      assert task.github_repo_id == github_repo.id

      assert_received({:post, "https://api.github.com/repos/foo/bar/issues", _body, _headers, _options})
    end

    test "if github process fails, returns {:error, :github}" do
      attrs = valid_attrs()
      project = Repo.one(CodeCorps.Project)
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      insert(:project_github_repo, project: project, github_repo: github_repo)

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :github} ==
          attrs
          |> Map.put("github_repo_id", github_repo.id)
          |> Task.Service.create
      end

      refute Repo.one(Task)
      assert_received({:post, "https://api.github.com/repos/foo/bar/issues", _body, _headers, _options})
    end
  end

  describe "update/2" do
    @update_attrs %{"title" => "foo", "markdown" => "bar", "status" => "closed"}

    test "updates task" do
      task = insert(:task)
      {:ok, updated_task} = task |> Task.Service.update(@update_attrs)

      assert updated_task.id == task.id
      assert updated_task.title == @update_attrs["title"]
      assert updated_task.markdown == @update_attrs["markdown"]
      assert updated_task.body != task.body
      refute task.github_issue_id
      refute task.github_repo_id

      refute_received({:patch, "https://api.github.com/" <> _rest, _body, _headers, _options})
    end

    test "sets modified_from to 'code_corps'" do
      task = insert(:task, modified_from: "github")
      {:ok, updated_task} = task |> Task.Service.update(@update_attrs)

      assert updated_task.modified_from == "code_corps"
    end

    test "returns {:error, changeset} if there are validation errors" do
      task = insert(:task)
      {:error, changeset} = task |> Task.Service.update(%{"title" => nil})

      refute changeset.valid?

      refute_received({:patch, "https://api.github.com/" <> _rest, _body, _headers, _options})
    end

    test "creates a github issue if task is just now connected to a repo" do
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      task = insert(:task)

      attrs = @update_attrs |> Map.put("github_repo_id", github_repo.id)

      {:ok, updated_task} = task |> Task.Service.update(attrs)

      assert updated_task.github_issue_id
      assert updated_task.github_repo_id == github_repo.id

      assert_received({:post, "https://api.github.com/repos/foo/bar/issues", _body, _headers, _options})
    end

    test "propagates changes to github if task is synced to github issue" do
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      github_issue = insert(:github_issue, number: 5)
      task = insert(:task, github_repo: github_repo, github_issue: github_issue)

      {:ok, updated_task} = task |> Task.Service.update(@update_attrs)

      assert updated_task.id == task.id
      assert updated_task.title == @update_attrs["title"]
      assert updated_task.markdown == @update_attrs["markdown"]
      assert updated_task.body != task.body
      assert updated_task.github_issue_id
      assert updated_task.github_repo_id

      assert_received({:patch, "https://api.github.com/repos/foo/bar/issues/5", _body, _headers, _options})
    end

    test "reports {:error, :github}, makes no changes at all if there is a github api error" do
      github_repo =
        :github_repo
        |> insert(github_account_login: "foo", name: "bar")

      github_issue = insert(:github_issue, number: 5)
      task = insert(:task, github_repo: github_repo, github_issue: github_issue)

      with_mock_api(CodeCorps.GitHub.FailureAPI) do
        assert {:error, :github} == task |> Task.Service.update(@update_attrs)
      end

      updated_task = Repo.one(Task)

      assert updated_task.id == task.id
      assert updated_task.title == task.title
      assert updated_task.markdown == task.markdown
      assert updated_task.body == task.body
      assert updated_task.github_issue_id == task.github_issue_id
      assert updated_task.github_repo_id == task.github_repo_id

      assert_received({:patch, "https://api.github.com/repos/foo/bar/issues/5", _body, _headers, _options})
    end
  end
end
