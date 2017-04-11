defmodule CodeCorps.Web.ProjectSkillTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Web.ProjectSkill

  test "changeset with valid attributes" do
    project_id = insert(:project).id
    skill_id = insert(:skill).id

    changeset = ProjectSkill.create_changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
    assert changeset.valid?
  end

  test "changeset requires project_id" do
    skill_id = insert(:skill).id

    changeset = ProjectSkill.create_changeset(%ProjectSkill{}, %{skill_id: skill_id})

    refute changeset.valid?
    assert_error_message(changeset, :project_id, "can't be blank")
  end

  test "changeset requires skill_id" do
    project_id = insert(:project).id

    changeset = ProjectSkill.create_changeset(%ProjectSkill{}, %{project_id: project_id})

    refute changeset.valid?
    assert_error_message(changeset, :skill_id, "can't be blank")
  end

  test "changeset requires id of actual project" do
    project_id = -1
    skill_id = insert(:skill).id

    {result, changeset} =
      ProjectSkill.create_changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :project, "does not exist")
  end

  test "changeset requires id of actual skill" do
    project_id = insert(:project).id
    skill_id = -1

    {result, changeset} =
      ProjectSkill.create_changeset(%ProjectSkill{}, %{project_id: project_id, skill_id: skill_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :skill, "does not exist")
  end
end
