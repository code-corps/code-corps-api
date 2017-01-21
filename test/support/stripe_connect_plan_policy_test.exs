defmodule CodeCorps.StripeConnectPlanPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.StripeConnectPlanPolicy, only: [show?: 2, create?: 2]
  import CodeCorps.StripeConnectPlan, only: [create_changeset: 2]

  defp setup_related_records do
    user = insert(:user)
    organization = insert(:organization)
    project = insert(:project, organization: organization)

    {user, organization, project}
  end

  defp setup_plan(project) do
    insert(:stripe_connect_plan, project: project)
  end

  defp setup_membership(_, _, nil), do: nil
  defp setup_membership(user, organization, role) do
    insert(:organization_membership, role: role, member: user, organization: organization)
  end

  defp setup_data_for_role(role) do
    {user, organization, project} = setup_related_records
    setup_membership(user, organization, role)
    plan = setup_plan(project)

    {user, plan}
  end

  describe "show?" do
    test "returns true when user is owner of organization" do
      {user, plan} = setup_data_for_role("owner")
      assert show?(user, plan)
    end

    test "returns false when user is admin of organization" do
      {user, plan} = setup_data_for_role("admin")
      refute show?(user, plan)
    end

    test "returns false when user is pending member of organization" do
      {user, plan} = setup_data_for_role("pending")

      refute show?(user, plan)
    end

    test "returns false when user is contributor of organization" do
      {user, plan} = setup_data_for_role("contributor")

      refute show?(user, plan)
    end

    test "returns false when user is not member of organization" do
      {user, plan} = setup_data_for_role(nil)

      refute show?(user, plan)
    end
  end

  defp setup_changeset_for_role(role) do
    {user, organization, project} = setup_related_records
    setup_membership(user, organization, role)
    changeset = setup_changeset(project)

    {user, changeset}
  end

  defp setup_changeset(project), do: %CodeCorps.StripeConnectPlan{} |> create_changeset(%{project_id: project.id})

  describe "create?" do
    test "returns true when user is owner of organization" do
      {user, changeset} = setup_changeset_for_role("owner")
      assert create?(user, changeset)
    end

    test "returns false when user is admin of organization" do
      {user, changeset} = setup_changeset_for_role("admin")
      refute create?(user, changeset)
    end

    test "returns false when user is pending member of organization" do
      {user, changeset} = setup_changeset_for_role("pending")

      refute create?(user, changeset)
    end

    test "returns false when user is contributor of organization" do
      {user, changeset} = setup_changeset_for_role("contributor")

      refute create?(user, changeset)
    end

    test "returns false when user is not member of organization" do
      {user, changeset} = setup_changeset_for_role(nil)

      refute create?(user, changeset)
    end
  end
end
