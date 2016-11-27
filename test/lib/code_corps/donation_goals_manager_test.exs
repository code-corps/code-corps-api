defmodule CodeCorps.DonationGoalsManagerTest do
  use ExUnit.Case, async: true

  use CodeCorps.ModelCase

  alias CodeCorps.DonationGoal
  alias CodeCorps.DonationGoalsManager

  defp assert_current_goal_id(goal_id) do
    current_goal =
      DonationGoal
      |> Repo.get_by(current: true)
    assert current_goal.id == goal_id
  end

  defp donate(plan, amount) do
    insert(:stripe_connect_subscription, quantity: amount, stripe_connect_plan: plan)
  end

  describe "create/1" do
    test "inserts new goal, returns {:ok, record}" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)

      {:ok, %DonationGoal{} = donation_goal} = DonationGoalsManager.create(%{amount: 10, description: "Test", project_id: project.id})
      assert_current_goal_id(donation_goal.id)
    end

    test "returns {:error, changeset} if there are validation errors" do
      {:error, %Ecto.Changeset{} = changeset} = DonationGoalsManager.create(%{amount: 10})
      refute changeset.valid?
    end

    test "sets current goal correctly when amount exists already" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)
      insert(:stripe_connect_subscription, quantity: 10, stripe_connect_plan: plan)

      {:ok, first_goal} = DonationGoalsManager.create(%{amount: 20, description: "Test", project_id: project.id})

      assert_current_goal_id(first_goal.id)

      {:ok, second_goal} = DonationGoalsManager.create(%{amount: 15, description: "Test", project_id: project.id})

      assert_current_goal_id(second_goal.id)
    end

    test "sets current goal correctly" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)

      insert(:stripe_connect_subscription, quantity: 5, stripe_connect_plan: plan)

      {:ok, first_goal} = DonationGoalsManager.create(%{amount: 10, description: "Test", project_id: project.id})

      # total donated is 5,
      # only goal inserted is the first goal
      assert_current_goal_id(first_goal.id)

      {:ok, second_goal} = DonationGoalsManager.create(%{amount: 7, description: "Test", project_id: project.id})

      assert_current_goal_id(second_goal.id)

      {:ok, _} = DonationGoalsManager.create(%{amount: 20, description: "Test", project_id: project.id})

      # total donated is still 5
      # first goal larger than 5 is the second goal
      assert_current_goal_id(second_goal.id)

      insert(:stripe_connect_subscription, quantity: 15, stripe_connect_plan: plan)

      {:ok, fourth_goal} = DonationGoalsManager.create(%{amount: 30, description: "Test", project_id: project.id})

      # total donated is 20.
      # first applicable goal is fourth goal, with an amount of 30
      assert_current_goal_id(fourth_goal.id)

      insert(:stripe_connect_subscription, quantity: 30, stripe_connect_plan: plan)

      {:ok, fourth_goal} = DonationGoalsManager.create(%{amount: 40, description: "Test", project_id: project.id})

      # total donated is 45, which is more than any defined goal
      # largest goal inserted after change the fourth goal, with an amount of 40
      assert_current_goal_id(fourth_goal.id)
    end
  end

  describe "update/2" do
    test "updates existing goal, returns {:ok, record}" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)
      donation_goal = insert(:donation_goal, amount: 10, project: project)

      {:ok, %DonationGoal{} = updated_goal} = DonationGoalsManager.update(donation_goal, %{amount: 15})
      assert_current_goal_id(updated_goal.id)
      assert updated_goal.id == donation_goal.id
    end
    test "returns {:error, changeset} if there are validation errors" do
      project = insert(:project)
      insert(:stripe_connect_plan, project: project)
      donation_goal = insert(:donation_goal, amount: 10, project: project)

      {:error, %Ecto.Changeset{} = changeset} = DonationGoalsManager.update(donation_goal, %{amount: nil})
      refute changeset.valid?
    end

    test "sets current goal correctly" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)
      goal_1 = insert(:donation_goal, amount: 10, project: project)
      goal_2 = insert(:donation_goal, amount: 15, project: project)
      insert(:donation_goal, amount: 20, project: project)

      DonationGoalsManager.update(goal_1, %{amount: 11})

      # amount donated is 0, first goal above that is still goal 1
      assert_current_goal_id(goal_1.id)

      DonationGoalsManager.update(goal_1, %{amount: 21})

      # amount donated is still 0, first goal above that is now goal 2
      assert_current_goal_id(goal_2.id)

      insert(:stripe_connect_subscription, quantity: 25, stripe_connect_plan: plan)

      DonationGoalsManager.update(goal_1, %{amount: 21})

      # amount donated is now 25
      # this is more than any current goal
      # largest goal is goal 1, with 21
      assert_current_goal_id(goal_1.id)

      DonationGoalsManager.update(goal_2, %{amount: 22})

      # amount donated is now 25
      # this is more than any current goal
      # largest goal is goal 2, with 22
      assert_current_goal_id(goal_2.id)

      DonationGoalsManager.update(goal_1, %{amount: 27})

      # amount donated is still 25
      # first goal higher than that is goal 1, with 27
      assert_current_goal_id(goal_1.id)
    end
  end



  describe "set_current_goal_for_project/1" do
    test "sets current goal correctly" do
      project = insert(:project)
      plan = insert(:stripe_connect_plan, project: project)

      goal_1 = insert(:donation_goal, amount: 10, project: project)
      goal_2 = insert(:donation_goal, amount: 15, project: project)
      goal_3 = insert(:donation_goal, amount: 20, project: project)

      plan |> donate(5)
      DonationGoalsManager.update_related_goals(goal_1)
      assert_current_goal_id(goal_1.id)

      plan |> donate(5) # total is now 10
      DonationGoalsManager.update_related_goals(goal_2)
      assert_current_goal_id(goal_2.id)

      plan |> donate(5) # total is now 15
      DonationGoalsManager.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      plan |> donate(5) # total is now 20
      DonationGoalsManager.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      plan |> donate(5) # total is now 25
      DonationGoalsManager.update_related_goals(goal_3)
      assert_current_goal_id(goal_3.id)

      goal_4 = insert(:donation_goal, amount: 30, project: project) # 30 is more than the current 25 total
      DonationGoalsManager.update_related_goals(goal_4)
      assert_current_goal_id(goal_4.id)
    end
  end
end
