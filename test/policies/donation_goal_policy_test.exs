defmodule CodeCorps.DonationGoalPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.DonationGoalPolicy, only: [create?: 2, update?: 2, delete?: 2]
  import CodeCorps.DonationGoal, only: [create_changeset: 2]

  alias CodeCorps.DonationGoal

  describe "create?" do
    test "returns true when user is project owner" do
      user = insert(:user)
      project = insert(:project, owner: user)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset)
    end

    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a pending project member" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "pending", user: user, project: project)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a project contributor" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "contributor", user: user, project: project)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a project admin" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true when user is project owner" do
      user = insert(:user)
      project = insert(:project, owner: user)

      record = insert(:donation_goal, project: project)
      assert update?(user, record)
    end

    test "returns false when user is a pending project member" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "pending", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns false when user is a project contributor" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "contributor", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns false when user is a project admin" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end
  end

  describe "delete?" do
    test "returns true when user is project owner" do
      user = insert(:user)
      project = insert(:project, owner: user)

      record = insert(:donation_goal, project: project)
      assert delete?(user, record)
    end

    test "returns false when user is a pending project member" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "pending", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project contributor" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "contributor", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project admin" do
      user = insert(:user)
      project = insert(:project)
      insert(:project_user, role: "admin", user: user, project: project)

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end
  end
end
