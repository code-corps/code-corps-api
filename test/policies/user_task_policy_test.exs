defmodule CodeCorps.UserTaskPolicyTest do
  @moduledoc false

  use CodeCorps.PolicyCase

  import CodeCorps.UserTaskPolicy, only: [create?: 2, update?: 2, delete?: 2]
  import CodeCorps.UserTask, only: [create_changeset: 2]

  alias CodeCorps.UserTask

  defp generate_data_for(role) do
    {user, project} = insert_user_and_project(role)

    task = case role do
      "author" -> insert(:task, project: project, user: user)
      _ -> insert(:task, project: project)
    end

    {user, task}
  end

  defp insert_user_and_project(role) do
    user = insert(:user)
    organization = insert(:organization)
    project = insert(:project, organization: organization)

    insert_membership(user, organization, role)

    {user, project}
  end

  defp insert_membership(_, _, role) when role in ~w(non-member author), do: nil
  defp insert_membership(user, organization, role) do
    insert(:organization_membership, organization: organization, member: user, role: role)
  end

  describe "create?" do
    test "returns false when user is not member of organization" do
      {user, task} = generate_data_for("non-member")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})
      refute create?(user, changeset)
    end

    test "returns false when user is pending member of organization" do
      {user, task} = generate_data_for("pending")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})
      refute create?(user, changeset)
    end

    test "returns true when user is contributor of organization" do
      {user, task} = generate_data_for("contributor")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is admin of organization" do
      {user, task} = generate_data_for("admin")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is owner of organization" do
      {user, task} = generate_data_for("owner")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is author of task" do
      {user, task} = generate_data_for("author")

      changeset = %UserTask{} |> create_changeset(%{task_id: task.id})

      assert create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns false when user is not member of organization" do
      {user, task} = generate_data_for("non-member")

      user_task = insert(:user_task, task: task)

      refute update?(user, user_task)
    end

    test "returns false when user is pending member of organization" do
      {user, task} = generate_data_for("pending")

      user_task = insert(:user_task, task: task)

      refute update?(user, user_task)
    end

    test "returns true when user is contributor of organization" do
      {user, task} = generate_data_for("contributor")

      user_task = insert(:user_task, task: task)

      assert update?(user, user_task)
    end

    test "returns true when user is admin of organization" do
      {user, task} = generate_data_for("admin")

      user_task = insert(:user_task, task: task)

      assert update?(user, user_task)
    end

    test "returns true when user is owner of organization" do
      {user, task} = generate_data_for("owner")

      user_task = insert(:user_task, task: task)

      assert update?(user, user_task)
    end

    test "returns true when user is author of task" do
      {user, task} = generate_data_for("author")

      user_task = insert(:user_task, task: task)

      assert update?(user, user_task)
    end
  end

  describe "delete?" do
    test "returns false when user is not member of organization" do
      {user, task} = generate_data_for("non-member")

      user_task = insert(:user_task, task: task)

      refute delete?(user, user_task)
    end

    test "returns false when user is pending member of organization" do
      {user, task} = generate_data_for("pending")

      user_task = insert(:user_task, task: task)

      refute delete?(user, user_task)
    end

    test "returns true when user is contributor of organization" do
      {user, task} = generate_data_for("contributor")

      user_task = insert(:user_task, task: task)

      assert delete?(user, user_task)
    end

    test "returns true when user is admin of organization" do
      {user, task} = generate_data_for("admin")

      user_task = insert(:user_task, task: task)

      assert delete?(user, user_task)
    end

    test "returns true when user is owner of organization" do
      {user, task} = generate_data_for("owner")

      user_task = insert(:user_task, task: task)

      assert delete?(user, user_task)
    end

    test "returns true when user is author of task" do
      {user, task} = generate_data_for("author")

      user_task = insert(:user_task, task: task)

      assert delete?(user, user_task)
    end
  end
end
