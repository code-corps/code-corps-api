defmodule CodeCorps.Policy.TaskTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Task, only: [create?: 2, update?: 2]
  import CodeCorps.Task, only: [create_changeset: 2]

  alias CodeCorps.Task

  describe "create?" do
    test "returns true when user is task author" do
      user = insert(:user)
      changeset = %Task{} |> create_changeset(%{user_id: user.id})

      assert create?(user, changeset)
    end

    test "returns false when user is not the author" do
      user = insert(:user)
      changeset = %Task{} |> create_changeset(%{user_id: -1})

      refute create?(user, changeset)
    end
  end

  describe "update" do
    test "returns true when user is the task author" do
      user = insert(:user)
      task = insert(:task, user: user)

      assert update?(user, task)
    end

    test "returns false when user is not associated to project or task" do
      user = insert(:user)
      task = insert(:task)

      refute update?(user, task)
    end

    test "returns false when user is a pending member of project" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      task = insert(:task, project: project)

      refute update?(user, task)
    end

    test "returns false when user is a contributing member of project" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      task = insert(:task, project: project)

      refute update?(user, task)
    end

    test "returns true when user is an admin member of project" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      task = insert(:task, project: project)

      assert update?(user, task)
    end

    test "returns true when user is the owner of the project" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      task = insert(:task, project: project)

      assert update?(user, task)
    end

  end
end
