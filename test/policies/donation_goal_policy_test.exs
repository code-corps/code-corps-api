defmodule CodeCorps.Web.DonationGoalPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.DonationGoalPolicy, only: [create?: 2, update?: 2, delete?: 2]
  import CodeCorps.Web.DonationGoal, only: [create_changeset: 2]

  alias CodeCorps.Web.DonationGoal

  describe "create?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns false when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      refute create?(user, changeset)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})
      assert create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns false when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      record = insert(:donation_goal, project: project)
      refute update?(user, record)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      record = insert(:donation_goal, project: project)
      assert update?(user, record)
    end
  end

  describe "delete?" do
    test "returns false when user is not a project member" do
      user = insert(:user)
      project = insert(:project)

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns false when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")

      record = insert(:donation_goal, project: project)
      refute delete?(user, record)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      record = insert(:donation_goal, project: project)
      assert delete?(user, record)
    end
  end
end
