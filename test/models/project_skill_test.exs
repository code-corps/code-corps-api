defmodule CodeCorps.ProjectSkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.ProjectSkill

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    project_id = insert_project().id
    skill_id = insert_skill().id

    changeset = ProjectSkill.changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
    assert changeset.valid?
  end

  test "changeset requires project_id" do
    skill_id = insert_skill().id

    changeset = ProjectSkill.changeset(%ProjectSkill{}, %{skill_id: skill_id})

    refute changeset.valid?
    assert changeset.errors[:project_id] == {"can't be blank", []}
  end

  test "changeset requires skill_id" do
    project_id = insert_project().id

    changeset = ProjectSkill.changeset(%ProjectSkill{}, %{project_id: project_id})

    refute changeset.valid?
    assert changeset.errors[:skill_id] == {"can't be blank", []}
  end

  test "changeset requires id of actual project" do
    project_id = -1
    skill_id = insert_skill().id

    { result, changeset } =
      ProjectSkill.changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:project] == {"does not exist", []}
  end

  test "changeset requires id of actual skill" do
    project_id = insert_project().id
    skill_id = -1

    { result, changeset } =
      ProjectSkill.changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert changeset.errors[:skill] == {"does not exist", []}
  end

end
