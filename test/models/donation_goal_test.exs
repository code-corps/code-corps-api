defmodule CodeCorps.Web.DonationGoalTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.Web.DonationGoal

  describe "%create_changeset/2" do
    test "requires amount, description and project_id" do
      changeset = DonationGoal.create_changeset(%DonationGoal{}, %{})

      refute changeset.valid?
      changeset |> assert_validation_triggered(:amount, :required)
      changeset |> assert_validation_triggered(:description, :required)
      changeset |> assert_validation_triggered(:project_id, :required)
    end

    test "ensures project with specified id actually exists" do
      attrs = %{amount: 100, description: "Bar", project_id: -1}
      {result, changeset} =
        %DonationGoal{}
        |> DonationGoal.create_changeset(attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      changeset |> assert_error_message(:project, "does not exist")
    end
  end

  describe "&update_changeset/2" do
    test "requires amount, description" do
      attrs = %{amount: nil, description: nil}
      donation_goal = insert(:donation_goal)
      changeset = DonationGoal.update_changeset(donation_goal, attrs)

      refute changeset.valid?

      changeset |> assert_validation_triggered(:amount, :required)
      changeset |> assert_validation_triggered(:description, :required)
    end
  end

  describe "&set_current_changeset/2" do
    test "requires current" do
      attrs = %{current: nil}
      donation_goal = insert(:donation_goal)
      changeset = DonationGoal.set_current_changeset(donation_goal, attrs)

      refute changeset.valid?
      changeset |> assert_validation_triggered(:current, :required)
    end

    test "ensures only one donation goal per project can be current" do
      project = insert(:project)
      insert(:donation_goal, current: true, project: project)
      donation_goal = insert(:donation_goal, project: project)

      attrs = %{current: true}
      changeset = DonationGoal.set_current_changeset(donation_goal, attrs)

      assert changeset.valid?

      {:error, errored_changeset} = Repo.update(changeset)

      assert_error_message(errored_changeset, :current, "has already been taken")
    end
  end
end
