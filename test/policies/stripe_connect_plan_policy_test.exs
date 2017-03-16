defmodule CodeCorps.StripeConnectPlanPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.StripeConnectPlanPolicy, only: [show?: 2, create?: 2]
  import CodeCorps.StripeConnectPlan, only: [create_changeset: 2]

  alias CodeCorps.StripeConnectPlan

  describe "show?" do
    test "returns true when user is owner of project" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      plan = insert(:stripe_connect_plan, project: project)

      assert show?(user, plan)
    end

    test "returns false otherwise" do
      user = insert(:user)
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)

      refute show?(user, plan)
    end
  end

  describe "create?" do
    test "returns true when user is owner of organization" do
      %{project: project, user: user} = insert(:project_user, role: "owner")

      changeset = create_changeset(%StripeConnectPlan{}, %{project_id: project.id})
      assert create?(user, changeset)
    end

    test "returns false otherwise" do
      user = insert(:user)
      project = insert(:project)

      changeset = create_changeset(%StripeConnectPlan{}, %{project_id: project.id})
      refute create?(user, changeset)
    end
  end
end
