defmodule CodeCorps.Web.TaskSkillTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.Web.TaskSkill

  describe "create_changeset/2" do
    @required_attrs ~w(task_id skill_id)

    test "requires #{@required_attrs}" do
      changeset = TaskSkill.create_changeset(%TaskSkill{}, %{})

      assert_validation_triggered(changeset, :task_id, :required)
      assert_validation_triggered(changeset, :skill_id, :required)
    end

    test "ensures associated Task record exists" do
      skill = insert(:skill)
      changeset = TaskSkill.create_changeset(%TaskSkill{}, %{task_id: -1, skill_id: skill.id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :task, "does not exist")
    end

    test "ensures associated Skill record exists" do
      task = insert(:task)
      changeset = TaskSkill.create_changeset(%TaskSkill{}, %{task_id: task.id, skill_id: -1})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :skill, "does not exist")
    end

    test "ensures uniqueness of Skill/Task combination" do
      task_skill = insert(:task_skill)

      changeset = TaskSkill.create_changeset(%TaskSkill{}, %{task_id: task_skill.task_id, skill_id: task_skill.skill_id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :skill, "has already been taken")
    end
  end
end
