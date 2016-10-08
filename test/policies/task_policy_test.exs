defmodule CodeCorps.TaskPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.TaskPolicy, only: [create?: 2, update?: 2]
  import CodeCorps.Task, only: [create_changeset: 2]

  alias CodeCorps.Task

  describe "create" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %Task{} |> create_changeset(%{})

      assert create?(user, changeset) 
    end

    test "returns false when user is not the author" do
      user = build(:user)
      changeset = %Task{} |> create_changeset(%{task_type: "issue", user_id: "other"})

      refute create?(user, changeset) 
    end

    test "returns true when task is an issue" do
      user = insert(:user)
      changeset = %Task{} |> create_changeset(%{task_type: "issue", user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns true when task is an idea" do
      user = insert(:user)
      changeset = %Task{} |> create_changeset(%{task_type: "idea", user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns true when user is at least contributor of organization" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      insert(:organization_membership, role: "contributor", member: user, organization: organization)

      changeset = %Task{} |> create_changeset(%{project_id: project.id, task_type: "task", user_id: user.id})

      assert create?(user, changeset) 
    end

    test "returns false when user is not contributor and type is 'task'" do
      user = insert(:user)
      organization = insert(:organization)
      project = insert(:project, organization: organization)

      changeset = %Task{} |> create_changeset(%{project_id: project.id, task_type: "task", user_id: user.id})

      refute create?(user, changeset) 
    end
  end

  describe "update" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      task = build(:task)

      assert update?(user, task) 
    end
  end
end
