defmodule CodeCorps.StripeService.Validators.ProjectCanEnableDonationsTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.{Project}
  alias CodeCorps.StripeService.Validators.ProjectCanEnableDonations

  describe "validate" do
    test "succeeds when project has donation_goals and organization where charges and transfers are enabled" do
      organization = insert(:organization)
      project = insert(:project, organization: organization)
      insert(:donation_goal, project: project)
      insert(:stripe_connect_account, organization: organization, charges_enabled: true, transfers_enabled: true)

      project =
        Project
        |> Repo.get(project.id)
        |> Repo.preload([:donation_goals, [organization: :stripe_connect_account], :stripe_connect_plan])

      assert {:ok, _project} = ProjectCanEnableDonations.validate(project)
    end

    test "fails when project has a StripeConnectPlan" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)

      project =
        Project
        |> Repo.get(project.id)
        |> Repo.preload([:stripe_connect_plan])

      assert {:error, :project_has_plan} = ProjectCanEnableDonations.validate(project)
    end

    test "fails when project is not ready" do
      project = insert(:project)

      assert {:error, :project_not_ready} = ProjectCanEnableDonations.validate(project)
    end
  end
end
