defmodule CodeCorps.Services.DonationGoalsServiceTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  import CodeCorps.Project, only: [update_total_changeset: 2]

  alias CodeCorps.DonationGoal
  alias CodeCorps.Services.DonationGoalsService

  defp assert_current_goal_id(goal_id) do
    current_goal =
      DonationGoal
      |> Repo.get_by(current: true)

    assert current_goal.id == goal_id
  end

  defp set_donated(project, amount) do
    project |> update_total_changeset(%{total_monthly_donated: amount}) |> Repo.update
  end

  describe "create/1" do
    test "inserts new goal, returns {:ok, record}" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)

      {:ok, %DonationGoal{} = donation_goal} = DonationGoalsService.create(%{amount: 10, description: "Test", project_id: project.id})
      assert_current_goal_id(donation_goal.id)
    end

    test "returns {:error, changeset} if there are validation errors" do
      {:error, %Ecto.Changeset{} = changeset} = DonationGoalsService.create(%{amount: 10})
      refute changeset.valid?
    end

    test "sets current goal correctly when amount exists already" do
      project = insert(:project, total_monthly_donated: 10)

      {:ok, first_goal} = DonationGoalsService.create(%{amount: 20, description: "Test", project_id: project.id})

      assert_current_goal_id(first_goal.id)

      {:ok, second_goal} = DonationGoalsService.create(%{amount: 15, description: "Test", project_id: project.id})

      assert_current_goal_id(second_goal.id)
    end

    test "sets current goal correctly" do
      project = insert(:project, total_monthly_donated: 5)

      {:ok, first_goal} = DonationGoalsService.create(%{amount: 10, description: "Test", project_id: project.id})

      # total donated is 5,
      # only goal inserted is the first goal
      assert_current_goal_id(first_goal.id)

      {:ok, second_goal} = DonationGoalsService.create(%{amount: 7, description: "Test", project_id: project.id})

      assert_current_goal_id(second_goal.id)

      {:ok, _} = DonationGoalsService.create(%{amount: 20, description: "Test", project_id: project.id})

      # total donated is still 5
      # first goal larger than 5 is the second goal
      assert_current_goal_id(second_goal.id)

      project |> set_donated(20)

      {:ok, fourth_goal} = DonationGoalsService.create(%{amount: 30, description: "Test", project_id: project.id})

      # total donated is 20.
      # first applicable goal is fourth goal, with an amount of 30
      assert_current_goal_id(fourth_goal.id)

      project |> set_donated(45)

      {:ok, fourth_goal} = DonationGoalsService.create(%{amount: 40, description: "Test", project_id: project.id})

      # total donated is 45, which is more than any defined goal
      # largest goal inserted after change the fourth goal, with an amount of 40
      assert_current_goal_id(fourth_goal.id)
    end
  end

  describe "update/2" do
    test "updates existing goal, returns {:ok, record}" do
      project = insert(:project)
      donation_goal = insert(:donation_goal, amount: 10, project: project)

      {:ok, %DonationGoal{} = updated_goal} = DonationGoalsService.update(donation_goal, %{amount: 15})
      assert_current_goal_id(updated_goal.id)
      assert updated_goal.id == donation_goal.id
    end
    test "returns {:error, changeset} if there are validation errors" do
      project = insert(:project)
      donation_goal = insert(:donation_goal, amount: 10, project: project)

      {:error, %Ecto.Changeset{} = changeset} = DonationGoalsService.update(donation_goal, %{amount: nil})
      refute changeset.valid?
    end

    test "sets current goal correctly" do
      project = insert(:project)
      goal_1 = insert(:donation_goal, amount: 10, project: project)
      goal_2 = insert(:donation_goal, amount: 15, project: project)
      insert(:donation_goal, amount: 20, project: project)

      DonationGoalsService.update(goal_1, %{amount: 11})

      # amount donated is 0, first goal above that is still goal 1
      assert_current_goal_id(goal_1.id)

      DonationGoalsService.update(goal_1, %{amount: 21})

      # amount donated is still 0, first goal above that is now goal 2
      assert_current_goal_id(goal_2.id)

      project |> set_donated(25)

      DonationGoalsService.update(goal_1, %{amount: 21})

      # amount donated is now 25
      # this is more than any current goal
      # largest goal is goal 1, with 21
      assert_current_goal_id(goal_1.id)

      DonationGoalsService.update(goal_2, %{amount: 22})

      # amount donated is now 25
      # this is more than any current goal
      # largest goal is goal 2, with 22
      assert_current_goal_id(goal_2.id)

      DonationGoalsService.update(goal_1, %{amount: 27})

      # amount donated is still 25
      # first goal higher than that is goal 1, with 27
      assert_current_goal_id(goal_1.id)
    end
  end



  describe "set_current_goal_for_project/1" do
    test "sets current goal correctly" do
      project = insert(:project)

      goal_1 = insert(:donation_goal, amount: 10, project: project)
      goal_2 = insert(:donation_goal, amount: 15, project: project)
      goal_3 = insert(:donation_goal, amount: 20, project: project)

      project |> set_donated(5)
      DonationGoalsService.update_related_goals(goal_1)
      assert_current_goal_id(goal_1.id)

      project |> set_donated(10) # total is now 10
      DonationGoalsService.update_related_goals(goal_2)
      assert_current_goal_id(goal_2.id)

      project |> set_donated(15) # total is now 15
      DonationGoalsService.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      project |> set_donated(20) # total is now 20
      DonationGoalsService.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      project |> set_donated(25) # total is now 25
      DonationGoalsService.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      goal_4 = insert(:donation_goal, amount: 30, project: project) # 30 is more than the current 25 total
      DonationGoalsService.update_related_goals(goal_4)
      assert_current_goal_id(goal_4.id)
    end
  end
end
