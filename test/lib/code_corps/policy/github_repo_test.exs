defmodule CodeCorps.Policy.GithubRepoTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.GithubRepo, only: [update?: 3]

  alias CodeCorps.GithubRepo

  describe "update?/3" do
    test "returns true when user is adding project where they're an admin" do
      project = insert(:project)
      user = insert(:user)
      insert(:project_user, project: project, user: user, role: "admin")
      github_repo = %GithubRepo{project_id: project.id}

      assert update?(user, github_repo, %{})
    end

    test "returns true when user is removing project where they're an admin" do
      project = insert(:project)
      user = insert(:user)
      insert(:project_user, project: project, user: user, role: "admin")

      assert update?(user, %GithubRepo{}, %{"project_id" => project.id})
    end

    test "returns false for normal user" do
      project = insert(:project)
      user = insert(:user)
      github_repo = %GithubRepo{project_id: project.id}

      refute update?(user, github_repo, %{})
    end
  end
end
