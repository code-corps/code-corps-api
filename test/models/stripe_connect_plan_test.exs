defmodule CodeCorps.Web.StripeConnectPlanTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.StripeConnectPlan

  @valid_attrs %{
    id_from_stripe: "abc123"
  }

  @invalid_attrs %{}

  describe "create_changeset/2" do
    test "reports as valid when attributes are valid" do
      project_id = insert(:project).id

      changes = Map.merge(@valid_attrs, %{project_id: project_id})
      changeset = StripeConnectPlan.create_changeset(%StripeConnectPlan{}, changes)
      assert changeset.valid?
    end

    test "reports as invalid when attributes are invalid" do
      changeset = StripeConnectPlan.create_changeset(%StripeConnectPlan{}, @invalid_attrs)
      refute changeset.valid?

      assert_error_message(changeset, :id_from_stripe, "can't be blank")
      assert_error_message(changeset, :project_id, "can't be blank")
    end

    test "ensures associations link to records that exist" do
      attrs =  @valid_attrs |> Map.merge(%{project_id: -1})

      {result, changeset} =
        StripeConnectPlan.create_changeset(%StripeConnectPlan{}, attrs)
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :project, "does not exist")
    end
  end
end
