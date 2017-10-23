defmodule CodeCorps.Policy.ProjectUserTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.ProjectUser, only: [create?: 2, update?: 3, delete?: 2]

  describe "create?/2" do
    test "returns true when user is creating their own membership" do
      user = insert(:user)

      assert create?(user, %{"user_id" => user.id})
    end

    test "returns false for normal user, creating someone else's membership" do
      user = insert(:user)

      refute create?(user, %{"user_id" => "someone_else"})
    end
  end

  describe "update?/2" do
    test "returns false when user is non-member" do
      user = insert(:user)
      project_user = insert(:project_user)

      refute update?(user, project_user, %{})
    end

    test "returns false when user is pending" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "pending", user: user, project: project)

      project_user = insert(:project_user, project: project)

      refute update?(user, project_user, %{})
    end

    test "returns false when user is contributor" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "contributor", user: user, project: project)

      project_user = insert(:project_user, project: project)

      refute update?(user, project_user, %{})
    end

    test "returns true when user is admin, approving a pending membership" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "pending")

      assert update?(user, project_user, %{"role" => "contributor"})
    end

    test "returns false when user is admin, doing something other than approving a pending membership" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "contributor")

      refute update?(user, project_user, %{})
    end

    test "returns true when user is owner and is changing a role other than owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "owner", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "admin")

      assert update?(user, project_user, %{})
    end

    test "returns false when user is owner and is changing another owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "owner", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "owner")

      refute update?(user, project_user, %{})
    end
  end

  describe "delete?/2" do
    test "returns true when contributor is deleting their own membership" do
      user = insert(:user)
      project = insert(:project)

      project_user = insert(:project_user, project: project, user: user, role: "contributor")

      assert delete?(user, project_user)
    end

    test "returns true when admin is deleting a pending membership" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "pending")

      assert delete?(user, project_user)
    end

    test "returns true when admin is deleting a contributor" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "contributor")

      assert delete?(user, project_user)
    end

    test "returns false when admin is deleting another admin" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "admin")

      refute delete?(user, project_user)
    end

    test "returns false when admin is deleting an owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "owner")

      refute delete?(user, project_user)
    end

    test "returns true when owner is deleting an admin" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "owner", user: user, project: project)

      project_user = insert(:project_user, project: project, role: "admin")

      assert delete?(user, project_user)
    end
  end
end
