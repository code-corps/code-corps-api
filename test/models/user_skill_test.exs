defmodule CodeCorps.UserSkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.UserSkill

  test "valid_changeset_is_valid" do
    user_id = insert(:user).id
    skill_id = insert(:skill).id

    changeset = UserSkill.create_changeset(%UserSkill{}, %{user_id: user_id, skill_id: skill_id})
    assert changeset.valid?
  end

  test "changeset requires user_id" do
    skill_id = insert(:skill).id

    changeset = UserSkill.create_changeset(%UserSkill{}, %{skill_id: skill_id})

    refute changeset.valid?
    assert_error_message(changeset, :user_id, "can't be blank")
  end

  test "changeset requires skill_id" do
    user_id = insert(:user).id

    changeset = UserSkill.create_changeset(%UserSkill{}, %{user_id: user_id})

    refute changeset.valid?
    assert_error_message(changeset, :skill_id, "can't be blank")
  end

  test "changeset requires id of actual user" do
    user_id = -1
    skill_id = insert(:skill).id

    { result, changeset } =
      UserSkill.create_changeset(%UserSkill{}, %{user_id: user_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :user, "does not exist")
  end

  test "changeset requires id of actual skill" do
    user_id = insert(:user).id
    skill_id = -1

    { result, changeset } =
      UserSkill.create_changeset(%UserSkill{}, %{user_id: user_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :skill, "does not exist")
  end
end
