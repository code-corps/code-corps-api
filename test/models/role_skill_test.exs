defmodule CodeCorps.RoleSkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.RoleSkill

  test "changeset with valid attributes" do
    role_id = insert(:role).id
    skill_id = insert(:skill).id

    changeset = RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id, skill_id: skill_id})
    assert changeset.valid?
  end

  test "changeset requires role_id" do
    skill_id = insert(:skill).id

    changeset = RoleSkill.changeset(%RoleSkill{}, %{skill_id: skill_id})

    refute changeset.valid?
    assert changeset.errors[:role_id] == {"can't be blank", []}
  end

  test "changeset requires skill_id" do
    role_id = insert(:role).id

    changeset = RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id})

    refute changeset.valid?
    assert changeset.errors[:skill_id] == {"can't be blank", []}
  end

  test "changeset requires id of actual role" do
    role_id = -1
    skill_id = insert(:skill).id

    { result, changeset } =
      RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:role] == {"does not exist", []}
  end

  test "changeset requires id of actual skill" do
    role_id = insert(:role).id
    skill_id = -1

    { result, changeset } =
      RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:skill] == {"does not exist", []}
  end

  describe "when cat is added to attributes" do
    test "valid cat value is accepted" do
      role_id = insert(:role).id
      skill_id = insert(:skill).id
      cat_value = 1

      changeset = RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id, skill_id: skill_id, cat: cat_value})
      assert changeset.valid?
    end

    test "invalid cat value is rejected" do
      role_id = insert(:role).id
      skill_id = insert(:skill).id
      cat_value = 9

      changeset = RoleSkill.changeset(%RoleSkill{}, %{role_id: role_id, skill_id: skill_id, cat: cat_value})
      refute changeset.valid?
      assert changeset.errors[:cat] == {"is invalid", []}
    end
  end
end
