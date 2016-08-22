defmodule CodeCorps.UserRoleTest do
  use CodeCorps.ModelCase

  alias CodeCorps.UserRole

  test "valid_changeset_is_valid" do
    user_id = insert_user().id
    role_id = insert_role().id

    changeset = UserRole.changeset(%UserRole{}, %{user_id: user_id, role_id: role_id})
    assert changeset.valid?
  end

  test "changeset requires user_id" do
    role_id = insert_role().id

    changeset = UserRole.changeset(%UserRole{}, %{role_id: role_id})

    refute changeset.valid?
    assert changeset.errors[:user_id] == {"can't be blank", []}
  end

  test "changeset requires role_id" do
    user_id = insert_user().id

    changeset = UserRole.changeset(%UserRole{}, %{user_id: user_id})

    refute changeset.valid?
    assert changeset.errors[:role_id] == {"can't be blank", []}
  end

  test "changeset requires id of actual user" do
    user_id = -1
    role_id = insert_role().id

    { result, changeset } =
      UserRole.changeset(%UserRole{}, %{user_id: user_id, role_id: role_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:user] == {"does not exist", []}
  end

  test "changeset requires id of actual role" do
    user_id = insert_user().id
    role_id = -1

    { result, changeset } =
      UserRole.changeset(%UserRole{}, %{user_id: user_id, role_id: role_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:role] == {"does not exist", []}
  end
end
