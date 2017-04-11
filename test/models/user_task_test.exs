defmodule CodeCorps.Web.UserTaskTest do
  @moduledoc false

  use CodeCorps.ModelCase

  alias CodeCorps.Web.UserTask

  describe "create_changeset/2" do
    @required_attrs ~w(task_id user_id)

    test "requires #{@required_attrs}" do
      changeset = UserTask.create_changeset(%UserTask{}, %{})

      assert_validation_triggered(changeset, :task_id, :required)
      assert_validation_triggered(changeset, :user_id, :required)
    end

    test "ensures associated Task record exists" do
      user = insert(:user)
      changeset = UserTask.create_changeset(%UserTask{}, %{task_id: -1, user_id: user.id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :task, "does not exist")
    end

    test "ensures associated User record exists" do
      task = insert(:task)
      changeset = UserTask.create_changeset(%UserTask{}, %{task_id: task.id, user_id: -1})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :user, "does not exist")
    end

    test "ensures uniqueness of User/Task combination" do
      user_task = insert(:user_task)

      changeset = UserTask.create_changeset(%UserTask{}, %{task_id: user_task.task_id, user_id: user_task.user_id})

      {:error, response_changeset} = Repo.insert(changeset)
      assert_error_message(response_changeset, :user, "has already been taken")
    end
  end

  describe "update_changeset/2" do
    @required_attrs ~w(user_id)

    test "requires #{@required_attrs}" do
      user_task = insert(:user_task)

      changeset = UserTask.update_changeset(user_task, %{user_id: nil})

      assert_validation_triggered(changeset, :user_id, :required)
    end

    test "ensures associated User record exists" do
      user_task = insert(:user_task)

      changeset = UserTask.update_changeset(user_task, %{user_id: -1})

      {:error, response_changeset} = Repo.update(changeset)
      assert_error_message(response_changeset, :user, "does not exist")
    end
  end
end
