defmodule CodeCorps.UserCategoryTest do
  use CodeCorps.ModelCase

  import CodeCorps.Factories

  alias CodeCorps.UserCategory

  test "valid_changeset_is_valid" do
      user_id = insert(:user).id
      category_id = insert(:category).id

      changeset = UserCategory.changeset(%UserCategory{}, %{user_id: user_id, category_id: category_id})
      assert changeset.valid?
    end

    test "changeset requires user_id" do
      category_id = insert(:category).id

      changeset = UserCategory.changeset(%UserCategory{}, %{category_id: category_id})

      refute changeset.valid?
      assert changeset.errors[:user_id] == {"can't be blank", []}
    end

    test "changeset requires category_id" do
      user_id = insert(:user).id

      changeset = UserCategory.changeset(%UserCategory{}, %{user_id: user_id})

      refute changeset.valid?
      assert changeset.errors[:category_id] == {"can't be blank", []}
    end

    test "changeset requires id of actual user" do
      user_id = -1
      category_id = insert(:category).id

      { result, changeset } =
        UserCategory.changeset(%UserCategory{}, %{user_id: user_id, category_id: category_id})
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:user] == {"does not exist", []}
    end

    test "changeset requires id of actual category" do
      user_id = insert(:user).id
      category_id = -1

      { result, changeset } =
        UserCategory.changeset(%UserCategory{}, %{user_id: user_id, category_id: category_id})
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert changeset.errors[:category] == {"does not exist", []}
    end
end
