defmodule CodeCorps.Policy.TaskTest do
  use CodeCorps.PolicyCase

  alias CodeCorps.Policy

  describe "create?" do
    test "returns true when user is task author" do
      user = insert(:user)
      assert Policy.Task.create?(user, %{"user_id" => user.id})
    end

    test "returns false when user is not the author" do
      user = insert(:user)
      refute Policy.Task.create?(user, %{"user_id" => -1})
    end
  end

  describe "update?" do
    test "returns true when user is the task author" do
      user = insert(:user)
      task = insert(:task, user: user)

      assert Policy.Task.update?(user, task)
    end

    test "returns false when user is not associated to project or task" do
      user = insert(:user)
      task = insert(:task)

      refute Policy.Task.update?(user, task)
    end

    test "returns false when user is a pending member of project" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      task = insert(:task, project: project)

      refute Policy.Task.update?(user, task)
    end

    test "returns false when user is a contributing member of project" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      task = insert(:task, project: project)

      refute Policy.Task.update?(user, task)
    end

    test "returns true when user is an admin member of project" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      task = insert(:task, project: project)

      assert Policy.Task.update?(user, task)
    end

    test "returns true when user is the owner of the project" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      task = insert(:task, project: project)

      assert Policy.Task.update?(user, task)
    end

  end
end
