defmodule CodeCorps.GithubIssueAssigneeTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.GithubIssueAssignee

  describe "changeset/2" do
    @required_attrs ~w(github_issue_id github_user_id)

    test "requires #{@required_attrs}" do
      changeset = GithubIssueAssignee.changeset(%GithubIssueAssignee{}, %{})

      assert_validation_triggered(changeset, :github_issue_id, :required)
      assert_validation_triggered(changeset, :github_user_id, :required)
    end

    test "ensures associated GithubIssue record exists" do
      github_user = insert(:github_user)
      changeset = GithubIssueAssignee.changeset(%GithubIssueAssignee{}, %{github_issue_id: -1, github_user_id: github_user.id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :github_issue, "does not exist")
    end

    test "ensures associated GithubUser record exists" do
      github_issue = insert(:github_issue)
      changeset = GithubIssueAssignee.changeset(%GithubIssueAssignee{}, %{github_issue_id: github_issue.id, github_user_id: -1})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :github_user, "does not exist")
    end

    test "ensures uniqueness of GithubUser/GithubIssue combination" do
      github_issue = insert(:github_issue)
      github_user = insert(:github_user)
      insert(:github_issue_assignee, github_issue: github_issue, github_user: github_user)

      changeset = GithubIssueAssignee.changeset(%GithubIssueAssignee{}, %{github_issue_id: github_issue.id, github_user_id: github_user.id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :github_user, "has already been taken")
    end
  end
end
