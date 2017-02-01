defmodule CodeCorps.TaskSkillPolicyTest do
  @moduledoc false

  use CodeCorps.PolicyCase

  import CodeCorps.TaskSkillPolicy, only: [create?: 2, delete?: 2]
  import CodeCorps.TaskSkill, only: [create_changeset: 2]

  alias CodeCorps.TaskSkill

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

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})
      refute create?(user, changeset)
    end

    test "returns false when user is pending member of organization" do
      {user, task} = generate_data_for("pending")

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})
      refute create?(user, changeset)
    end

    test "returns true when user is contributor of organization" do
      {user, task} = generate_data_for("contributor")

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is admin of organization" do
      {user, task} = generate_data_for("admin")

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is owner of organization" do
      {user, task} = generate_data_for("owner")

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})
      assert create?(user, changeset)
    end

    test "returns true when user is author of task" do
      {user, task} = generate_data_for("author")

      changeset = %TaskSkill{} |> create_changeset(%{task_id: task.id})

      assert create?(user, changeset)
    end
  end

  describe "delete?" do
    test "returns false when user is not member of organization" do
      {user, task} = generate_data_for("non-member")

      task_skill = insert(:task_skill, task: task)

      refute delete?(user, task_skill)
    end

    test "returns false when user is pending member of organization" do
      {user, task} = generate_data_for("pending")

      task_skill = insert(:task_skill, task: task)

      refute delete?(user, task_skill)
    end

    test "returns true when user is contributor of organization" do
      {user, task} = generate_data_for("contributor")

      task_skill = insert(:task_skill, task: task)

      assert delete?(user, task_skill)
    end

    test "returns true when user is admin of organization" do
      {user, task} = generate_data_for("admin")

      task_skill = insert(:task_skill, task: task)

      assert delete?(user, task_skill)
    end

    test "returns true when user is owner of organization" do
      {user, task} = generate_data_for("owner")

      task_skill = insert(:task_skill, task: task)

      assert delete?(user, task_skill)
    end

    test "returns true when user is author of task" do
      {user, task} = generate_data_for("author")

      task_skill = insert(:task_skill, task: task)

      assert delete?(user, task_skill)
    end
  end
end
