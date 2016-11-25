defmodule CodeCorps.DonationGoalTest do
  use CodeCorps.ModelCase

  alias CodeCorps.DonationGoal

  describe "%create_changeset/2" do
    test "requires amount, description and project_id" do
      changeset = DonationGoal.create_changeset(%DonationGoal{}, %{})

      refute changeset.valid?
      assert changeset.errors[:amount] == {"can't be blank", []}
      assert changeset.errors[:description] == {"can't be blank", []}
      assert changeset.errors[:project_id] == {"can't be blank", []}
    end

    test "ensures project with specified id actually exists" do
      attrs = %{amount: 100, description: "Bar", project_id: -1}
      { result, changeset } =
        DonationGoal.create_changeset(%DonationGoal{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:project] == {"does not exist", []}
    end
  end

  describe "&update_changeset/2" do
    test "requires amount, description" do
      attrs = %{amount: nil, description: nil}
      donation_goal = insert(:donation_goal)
      changeset = DonationGoal.update_changeset(donation_goal, attrs)

      refute changeset.valid?
      assert changeset.errors[:amount] == {"can't be blank", []}
      assert changeset.errors[:description] == {"can't be blank", []}
    end
  end
end
