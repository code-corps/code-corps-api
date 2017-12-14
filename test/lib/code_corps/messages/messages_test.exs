defmodule CodeCorps.MessagesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import Ecto.Query, only: [where: 2]

  alias CodeCorps.{Conversation, Message, Messages}

  defp get_and_sort_ids(records) do
    records |> Enum.map(&Map.get(&1, :id)) |> Enum.sort
  end

  describe "list" do
    test "returns all records by default" do
      insert_list(3, :message)
      assert Message |> Messages.list(%{}) |> Enum.count == 3
    end

    test "can filter by project" do
      [project_1, project_2] = insert_pair(:project)
      messages_from_project_1 = insert_pair(:message, project: project_1)
      message_from_project_2 = insert(:message, project: project_2)

      results = Message |> Messages.list(%{"project_id" => project_1.id})
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        messages_from_project_1 |> get_and_sort_ids()

      results = Message |> Messages.list(%{"project_id" => project_2.id})
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_from_project_2.id]
    end

    test "can filter by author" do
      [author_1, author_2] = insert_pair(:user)
      messages_from_author_1 = insert_pair(:message, author: author_1)
      message_from_author_2 = insert(:message, author: author_2)

      results = Message |> Messages.list(%{"author_id" => author_1.id})
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        messages_from_author_1 |> get_and_sort_ids()

      results = Message |> Messages.list(%{"author_id" => author_2.id})
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_from_author_2.id]
    end

    test "can filter by list of ids" do
      [message_1, message_2, message_3] = insert_list(3, :message)

      params = %{"filter" => %{"id" => "#{message_1.id},#{message_3.id}"}}
      results = Message |> Messages.list(params)
      assert results |> Enum.count == 2
      assert results |> get_and_sort_ids() ==
        [message_1, message_3] |> get_and_sort_ids()

      params = %{"filter" => %{"id" => "#{message_2.id}"}}
      results = Message |> Messages.list(params)
      assert results |> Enum.count == 1
      assert results |> get_and_sort_ids() ==
        [message_2] |> get_and_sort_ids()
    end

    test "can apply multiple filters at once" do
      [project_1, project_2] = insert_pair(:project)
      [author_1, author_2] = insert_pair(:user)

      message_p1_a1 = insert(:message, project: project_1, author: author_1)
      message_p1_a2 = insert(:message, project: project_1, author: author_2)
      message_p2_a1 = insert(:message, project: project_2, author: author_1)
      message_p2_a2 = insert(:message, project: project_2, author: author_2)

      params = %{"project_id" => project_1.id, "author_id" => author_1.id}
      results = Message |> Messages.list(params)
      assert results |> get_and_sort_ids() == [message_p1_a1.id]

      params = %{"project_id" => project_1.id, "author_id" => author_2.id}
      results = Message |> Messages.list(params)
      assert results |> get_and_sort_ids() == [message_p1_a2.id]

      params = %{"project_id" => project_2.id, "author_id" => author_1.id}
      results = Message |> Messages.list(params)
      assert results |> get_and_sort_ids() == [message_p2_a1.id]

      params = %{"project_id" => project_2.id, "author_id" => author_2.id}
      results = Message |> Messages.list(params)
      assert results |> get_and_sort_ids() == [message_p2_a2.id]

      params = %{
        "filter" => %{"id" => "#{message_p1_a1.id},#{message_p2_a1.id}"},
        "project_id" => project_1.id
      }
      results = Message |> Messages.list(params)

      assert results |> get_and_sort_ids() == [message_p1_a1.id]
    end

    test "builds upon the provided scope" do
      [%{id: project_1_id} = project_1, project_2] = insert_pair(:project)
      [author_1, author_2] = insert_pair(:user)

      message_p1_a1 = insert(:message, project: project_1, author: author_1)
      message_p1_a2 = insert(:message, project: project_1, author: author_2)
      message_p2_a1 = insert(:message, project: project_2, author: author_1)
      message_p2_a2 = insert(:message, project: project_2, author: author_2)

      params = %{"author_id" => author_1.id}
      result_ids =
        Message
        |> where(project_id: ^project_1_id)
        |> Messages.list(params)
        |> get_and_sort_ids()

      assert message_p1_a1.id in result_ids
      refute message_p1_a2.id in result_ids
      refute message_p2_a1.id in result_ids
      refute message_p2_a2.id in result_ids
    end
  end

  describe "list_conversations/2" do
    test "returns all records by default" do
      insert_list(3, :conversation)
      assert Conversation |> Messages.list_conversations(%{}) |> Enum.count == 3
    end

    test "can filter by project" do
      [%{project: project_1} = message_1, %{project: project_2} = message_2] =
        insert_pair(:message)

      conversation_1 = insert(:conversation, message: message_1)
      conversation_2 = insert(:conversation, message: message_2)

      result_ids =
        Conversation
        |> Messages.list_conversations(%{"project_id" => project_1.id})
        |> get_and_sort_ids()

      assert result_ids |> Enum.count == 1
      assert conversation_1.id in result_ids
      refute conversation_2.id in result_ids

      result_ids =
        Conversation
        |> Messages.list_conversations(%{"project_id" => project_2.id})
        |> get_and_sort_ids()

      assert result_ids |> Enum.count == 1
      refute conversation_1.id in result_ids
      assert conversation_2.id in result_ids
    end

    test "can filter by status" do
      message_started_by_admin = insert(:message, initiated_by: "admin")
      message_started_by_user = insert(:message, initiated_by: "user")

      conversation_started_by_admin_without_reply =
        insert(:conversation, message: message_started_by_admin)
      conversation_started_by_admin_with_reply =
        insert(:conversation, message: message_started_by_admin)
      insert(
        :conversation_part,
        conversation: conversation_started_by_admin_with_reply
      )

      conversation_started_by_user_without_reply =
        insert(:conversation, message: message_started_by_user)
      conversation_started_by_user_with_reply =
        insert(:conversation, message: message_started_by_user)
      insert(
        :conversation_part,
        conversation: conversation_started_by_user_with_reply
      )

      result_ids =
        Conversation
        |> Messages.list_conversations(%{"status" => "active"})
        |> get_and_sort_ids()

      refute conversation_started_by_admin_without_reply.id in result_ids
      assert conversation_started_by_admin_with_reply.id in result_ids
      assert conversation_started_by_user_without_reply.id in result_ids
      assert conversation_started_by_user_with_reply.id in result_ids

      result_ids =
        Conversation
        |> Messages.list_conversations(%{"status" => "any"})
        |> get_and_sort_ids()

      assert conversation_started_by_admin_without_reply.id in result_ids
      assert conversation_started_by_admin_with_reply.id in result_ids
      assert conversation_started_by_user_without_reply.id in result_ids
      assert conversation_started_by_user_with_reply.id in result_ids
    end

    test "builds upon the provided scope" do
      [project_1, project_2] = insert_pair(:project)
      [user_1, user_2] = insert_pair(:user)

      message_p1 = insert(:message, project: project_1)
      message_p2 = insert(:message, project: project_2)

      conversation_u1_p1 =
        insert(:conversation, user: user_1, message: message_p1)
      conversation_u1_p2 =
        insert(:conversation, user: user_1, message: message_p2)
      conversation_u2_p1 =
        insert(:conversation, user: user_2, message: message_p1)
      conversation_u2_p2 =
        insert(:conversation, user: user_2, message: message_p2)

      params = %{"project_id" => project_1.id}
      result_ids =
        Conversation
        |> where(user_id: ^user_1.id)
        |> Messages.list_conversations(params)
        |> get_and_sort_ids()

      assert conversation_u1_p1.id in result_ids
      refute conversation_u1_p2.id in result_ids
      refute conversation_u2_p1.id in result_ids
      refute conversation_u2_p2.id in result_ids
    end

    test "supports multiple filters at once" do
      ## we create two messages started by admin, each on a different project
      %{project: project_1} = message_1_started_by_admin =
        insert(:message, initiated_by: "admin")
      %{project: project_2} = message_2_started_by_admin =
        insert(:message, initiated_by: "admin")

      # we create one conversation without a reply, to test the "status" filter

      conversation_started_by_admin_without_reply =
        insert(:conversation, message: message_1_started_by_admin)

      # we create two conversations with replies, on on each message
      # since the messages are on different projects, this allows us to
      # test the project filter

      conversation_started_by_admin_with_reply =
        insert(:conversation, message: message_1_started_by_admin)
      insert(
        :conversation_part,
        conversation: conversation_started_by_admin_with_reply
      )
      other_conversation_started_by_admin_with_reply =
        insert(:conversation, message: message_2_started_by_admin)
      insert(
        :conversation_part,
        conversation: other_conversation_started_by_admin_with_reply
      )

      params = %{"status" => "active", "project_id" => project_1.id}
      result_ids =
        Conversation
        |> Messages.list_conversations(params)
        |> get_and_sort_ids()

      # this means the status filter worked, because the first conv. belongs to
      # the message with the correct project
      refute conversation_started_by_admin_without_reply.id in result_ids
      # this conversation is active and belongs to the message with the
      # correct project
      assert conversation_started_by_admin_with_reply.id in result_ids
      # this conversation is active, but belongs to a message with a different
      # project
      refute other_conversation_started_by_admin_with_reply.id in result_ids

      params = %{"status" => "active", "project_id" => project_2.id}
      result_ids =
        Conversation
        |> Messages.list_conversations(params)
        |> get_and_sort_ids()

      refute conversation_started_by_admin_without_reply.id in result_ids
      refute conversation_started_by_admin_with_reply.id in result_ids
      assert other_conversation_started_by_admin_with_reply.id in result_ids
    end
  end
end
