defmodule CodeCorps.Policy.ProjectSkillTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.ProjectSkill, only: [create?: 2, delete?: 2]

  describe "create?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      params = %{project_id: project.id}
      refute create?(user, params)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      params = %{project_id: project.id}
      refute create?(user, params)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      params = %{project_id: project.id}
      refute create?(user, params)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      params = %{project_id: project.id}
      assert create?(user, params)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      params = %{project_id: project.id}
      assert create?(user, params)
    end
  end

  describe "delete?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      record = insert(:project_skill, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      record = insert(:project_skill, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      record = insert(:project_skill, project: project)
      refute delete?(user, record)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      record = insert(:project_skill, project: project)
      assert delete?(user, record)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      record = insert(:project_skill, project: project)
      assert delete?(user, record)
    end
  end
end
