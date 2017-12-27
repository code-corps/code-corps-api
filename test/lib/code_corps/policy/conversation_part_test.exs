defmodule CodeCorps.Policy.ConversationPartTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.ConversationPart, only: [create?: 2, scope: 2, show?: 2]

  alias CodeCorps.{ConversationPart, Repo}

  defp params(user, conversation) do
    %{
      "author_id" => user.id,
      "body" => "Test",
      "conversation_id" => conversation.id
    }
  end

  describe "scope" do
    test "returns all records for admin user" do
      insert_list(3, :conversation_part)
      user = insert(:user, admin: true)

      assert ConversationPart |> scope(user) |> Repo.all |> Enum.count == 3
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

      message_in_project_applied_to =
        insert(:message, project: project_user_applied_to)

      message_in_contributing_project =
        insert(:message, project: project_user_contributes_to)

      message_in_administered_project =
        insert(:message, project: project_user_administers)

      message_in_owned_project =
        insert(:message, project: project_user_owns)

      conversation_when_target = insert(:conversation, user: user)
      conversation_when_pending =
        insert(:conversation, message: message_in_project_applied_to)
      conversation_when_contributor =
        insert(:conversation, message: message_in_contributing_project)
      conversation_when_admin =
        insert(:conversation, message: message_in_administered_project)
      conversation_when_owner =
        insert(:conversation, message: message_in_owned_project)
      some_other_conversation = insert(:conversation)

      part_in_conversation_when_target =
        insert(:conversation_part, conversation: conversation_when_target)
      part_in_project_applied_to =
        insert(:conversation_part, conversation: conversation_when_pending)
      part_in_contributing_project =
        insert(:conversation_part, conversation: conversation_when_contributor)
      part_in_administered_project =
        insert(:conversation_part, conversation: conversation_when_admin)
      part_in_owned_project =
        insert(:conversation_part, conversation: conversation_when_owner)
      part_in_some_other_conversation =
        insert(:conversation_part, conversation: some_other_conversation)
      part_closed =
        insert(:conversation_part, conversation: conversation_when_target, part_type: "closed")

      result_ids =
        ConversationPart
        |> scope(user)
        |> Repo.all
        |> Enum.map(&Map.get(&1, :id))

      assert part_in_conversation_when_target.id in result_ids
      refute part_in_project_applied_to.id in result_ids
      refute part_in_contributing_project.id in result_ids
      assert part_in_administered_project.id in result_ids
      assert part_in_owned_project.id in result_ids
      refute part_in_some_other_conversation.id in result_ids
      refute part_closed.id in result_ids
    end
  end

  describe "create?" do
    test "returns true when user is the target" do
      user = insert(:user)
      message = insert(:message)
      conversation = insert(:conversation, message: message, user: user)
      params = params(user, conversation)

      assert create?(user, params)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      params = params(user, conversation)

      refute create?(user, params)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      params = params(user, conversation)

      refute create?(user, params)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      params = params(user, conversation)

      assert create?(user, params)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      params = params(user, conversation)

      assert create?(user, params)
    end
  end

  describe "show?" do
    test "returns true when user is the target" do
      user = insert(:user)
      message = insert(:message)
      conversation = insert(:conversation, message: message, user: user)
      conversation_part = insert(:conversation_part, conversation: conversation)

      assert show?(user, conversation_part)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      conversation_part = insert(:conversation_part, conversation: conversation)

      refute show?(user, conversation_part)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      conversation_part = insert(:conversation_part, conversation: conversation)

      refute show?(user, conversation_part)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      conversation_part = insert(:conversation_part, conversation: conversation)

      assert show?(user, conversation_part)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, project: project)
      conversation = insert(:conversation, message: message)
      conversation_part = insert(:conversation_part, conversation: conversation)

      assert show?(user, conversation_part)
    end
  end
end
