defmodule CodeCorps.Policy.MessageTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Message, only: [create?: 2, show?: 2, scope: 2]

  alias CodeCorps.{Message, Repo}

  defp params_for(initiated_by, project_id, author_id) do
    %{
      "initiated_by" => initiated_by,
      "author_id" => author_id,
      "project_id" => project_id
    }
  end

  describe "scope" do
    test "returns all records for admin user" do
      insert_list(3, :message)
      user = insert(:user, admin: true)

      assert Message |> scope(user) |> Repo.all |> Enum.count == 3
    end

    test "returns records where user is the author or they administer the project" do
      user = insert(:user, admin: false)

      %{project: project_user_applied_to} =
        insert(:project_user, user: user, role: "pending")

      %{project: project_user_contributes_to} =
        insert(:project_user, user: user, role: "contributor")

      %{project: project_user_administers} =
        insert(:project_user, user: user, role: "admin")

      %{project: other_project_user_administers} =
        insert(:project_user, user: user, role: "admin")


      %{project: project_user_owns} =
        insert(:project_user, user: user, role: "owner")

      message_authored_by = insert(:message, author: user)
      some_other_message = insert(:message)

      message_from_project_applied_to =
        insert(:message, project: project_user_applied_to)

      message_from_contributing_project =
        insert(:message, project: project_user_contributes_to)

      message_from_administered_project =
        insert(:message, project: project_user_administers)

      message_from_other_administered_project =
        insert(:message, project: other_project_user_administers)

      message_from_owned_project =
        insert(:message, project: project_user_owns)

      result_ids =
        Message
        |> scope(user)
        |> Repo.all
        |> Enum.map(&Map.get(&1, :id))

      assert message_authored_by.id in result_ids
      refute message_from_project_applied_to.id in result_ids
      refute message_from_contributing_project.id in result_ids
      assert message_from_administered_project.id in result_ids
      assert message_from_other_administered_project.id in result_ids
      assert message_from_owned_project.id in result_ids
      refute some_other_message.id in result_ids
    end
  end

  describe "show?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      message = insert(:message, initiated_by: "user", author: author)

      assert show?(author, message)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      message = insert(:message, initiated_by: "user")

      refute show?(user, message)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end
  end

  describe "create?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      params = params_for("user", 1, author.id)

      assert create?(author, params)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      params = params_for("user", 1, -1)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns true when initiated by admin and user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end

    test "returns true when initiated by admin and user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end
  end
end
