defmodule CodeCorps.DonationGoalPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.DonationGoalPolicy, only: [create?: 2, update?: 2, delete?: 2]
  import CodeCorps.DonationGoal, only: [create_changeset: 2]

  alias CodeCorps.DonationGoal

  describe "create?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      changeset = %DonationGoal{} |> create_changeset(%{})

      assert create?(user, changeset)
    end

    test "returns true when user is organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "owner", member: user, organization: project.organization)
      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})

      assert create?(user, changeset)
    end

    test "returns false when user is less than organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "admin", member: user, organization: project.organization)
      changeset = %DonationGoal{} |> create_changeset(%{project_id: project.id})

      refute create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      record = insert(:donation_goal)
      assert update?(user, record)
    end

    test "returns true when user is organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "owner", member: user, organization: project.organization)
      record = insert(:donation_goal, project: project)

      assert update?(user, record)
    end

    test "returns false when user is less than organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "admin", member: user, organization: project.organization)
      record = insert(:donation_goal, project: project)

      refute update?(user, record)
    end
  end

  describe "delete?" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      record = insert(:donation_goal)
      assert delete?(user, record)
    end

    test "returns true when user is organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "owner", member: user, organization: project.organization)
      record = insert(:donation_goal, project: project)

      assert delete?(user, record)
    end

    test "returns false when user is less than organization owner" do
      user = insert(:user)
      project = insert(:project)
      insert(:organization_membership, role: "admin", member: user, organization: project.organization)
      record = insert(:donation_goal, project: project)

      refute delete?(user, record)
    end
  end
end
