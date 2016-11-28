defmodule CodeCorps.Services.ProjectServiceTest do
  use ExUnit.Case, async: true
  use CodeCorps.ModelCase

  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.Services.ProjectService

  describe "update_project_totals/1" do
    test "updates the project totals when has active subscriptions" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)
      insert(:stripe_connect_subscription, stripe_connect_plan: plan, quantity: 1000, status: "active")
      insert(:stripe_connect_subscription, stripe_connect_plan: plan, quantity: 1000, status: "active")

      repo_project =
        Project
        |> Repo.get(project.id)
        |> Repo.preload([:stripe_connect_plan])

      {:ok, result} = ProjectService.update_project_totals(repo_project)

      assert result.id == project.id
      assert result.total_monthly_donated == 2000
    end

    test "updates the project totals when has no active subscriptions" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)

      repo_project =
        Project
        |> Repo.get(project.id)
        |> Repo.preload([:stripe_connect_plan])

      {:ok, result} = ProjectService.update_project_totals(repo_project)

      assert result.id == project.id
      assert result.total_monthly_donated == 0
    end
  end
end
