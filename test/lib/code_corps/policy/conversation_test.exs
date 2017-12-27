defmodule CodeCorps.Policy.ConversationTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Conversation, only: [scope: 2, show?: 2, update?: 2]

  alias CodeCorps.{Conversation, Repo}

  describe "scope" do
    test "returns all records for admin user" do
      insert_list(3, :conversation)
      user = insert(:user, admin: true)

      assert Conversation |> scope(user) |> Repo.all |> Enum.count == 3
    end

    test "returns records where user is the author or they administer the project" do
      user = insert(:user, admin: false)

      %{project: project_user_applied_to} =
        insert(:project_user, user: user, role: "pending")

      %{project: project_user_contributes_to} =
        insert(:project_user, user: user, role: "contributor")

      %{project: project_user_administers} =
        insert(:project_user, user: user, role: "admin")

      %{project: project_user_owns} =
        insert(:project_user, user: user, role: "owner")

      message_authored_by = insert(:message, author: user)

      message_from_project_applied_to =
        insert(:message, project: project_user_applied_to)

      message_from_contributing_project =
        insert(:message, project: project_user_contributes_to)

      message_from_administered_project =
        insert(:message, project: project_user_administers)

      message_from_owned_project =
        insert(:message, project: project_user_owns)

      conversation_with = insert(:conversation, user: user)
      conversation_authored_by =
        insert(:conversation, message: message_authored_by)
      some_other_conversation = insert(:conversation)

      conversation_from_project_applied_to =
        insert(:conversation, message: message_from_project_applied_to)
      conversation_from_contributing_project =
        insert(:conversation, message: message_from_contributing_project)
      conversation_from_administered_project =
        insert(:conversation, message: message_from_administered_project)
      conversation_from_owned_project =
        insert(:conversation, message: message_from_owned_project)

      result_ids =
        Conversation
        |> scope(user)
        |> Repo.all
        |> Enum.map(&Map.get(&1, :id))

      assert conversation_with.id in result_ids
      assert conversation_authored_by.id in result_ids
      refute conversation_from_project_applied_to.id in result_ids
      refute conversation_from_contributing_project.id in result_ids
      assert conversation_from_administered_project.id in result_ids
      assert conversation_from_owned_project.id in result_ids
      refute some_other_conversation.id in result_ids
    end
  end

  describe "show?" do
    test "returns true when user is the target" do
      user = insert(:user)
      message = insert(:message)
      conversation = insert(:conversation, message: message, user: user)

      assert show?(user, conversation)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      refute show?(user, conversation)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      refute show?(user, conversation)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      assert show?(user, conversation)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      assert show?(user, conversation)
    end
  end

  describe "update?" do
    test "returns true when user is admin" do
      user = insert(:user, admin: true)
      message = insert(:message)
      conversation = insert(:conversation, message: message, user: user)

      assert update?(user, conversation)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      refute update?(user, conversation)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      refute update?(user, conversation)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      assert update?(user, conversation)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)

      assert update?(user, conversation)
    end
  end
end
