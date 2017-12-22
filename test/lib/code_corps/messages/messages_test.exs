defmodule CodeCorps.MessagesTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  use Phoenix.ChannelTest

  import Ecto.Query, only: [where: 2]

  alias CodeCorps.{
    Conversation, ConversationPart, Message, Messages,
    Emails.Transmissions.MessageInitiatedByProject,
    Emails.Transmissions.ReplyToConversation
  }
  alias Ecto.Changeset

  defp get_and_sort_ids(records) do
    records |> Enum.map(&Map.get(&1, :id)) |> Enum.sort
  end

  describe "list" do
    test "returns all records by default" do
      insert_list(3, :message)
      assert Message |> Messages.list(%{}) |> Enum.count == 3
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

    test "builds upon the provided scope" do
      [%{id: project_1_id} = project_1, project_2] = insert_pair(:project)
      [author_1, author_2] = insert_pair(:user)

      message_p1_a1 = insert(:message, project: project_1, author: author_1)
      message_p1_a2 = insert(:message, project: project_1, author: author_2)
      message_p2_a1 = insert(:message, project: project_2, author: author_1)
      message_p2_a2 = insert(:message, project: project_2, author: author_2)

      params = %{"filter" => %{"id" => "#{message_p1_a1.id}"}}
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
        |> Messages.list_conversations(%{"active" => true})
        |> get_and_sort_ids()

      refute conversation_started_by_admin_without_reply.id in result_ids
      assert conversation_started_by_admin_with_reply.id in result_ids
      assert conversation_started_by_user_without_reply.id in result_ids
      assert conversation_started_by_user_with_reply.id in result_ids

      result_ids =
        Conversation
        |> Messages.list_conversations(%{"status" => "open"})
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

      params = %{"active" => true, "project_id" => project_1.id}
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

      params = %{"active" => true, "project_id" => project_2.id}
      result_ids =
        Conversation
        |> Messages.list_conversations(params)
        |> get_and_sort_ids()

      refute conversation_started_by_admin_without_reply.id in result_ids
      refute conversation_started_by_admin_with_reply.id in result_ids
      assert other_conversation_started_by_admin_with_reply.id in result_ids
    end
  end

  describe "list_parts/2" do
    test "returns all records by default" do
      insert_list(3, :conversation_part)
      assert ConversationPart |> Messages.list_parts(%{}) |> Enum.count == 3
    end
  end

  describe "get_conversation/1" do
    test "gets a single conversation" do
      conversation = insert(:conversation)

      result = Messages.get_conversation(conversation.id)

      assert result.id == conversation.id
    end
  end

  describe "get_part/1" do
    test "gets a single part" do
      conversation_part = insert(:conversation_part)

      result = Messages.get_part(conversation_part.id)

      assert result.id == conversation_part.id
    end
  end

  describe "add_part/1" do
    test "creates a conversation part" do
      conversation = insert(:conversation)
      user = insert(:user)
      attrs = %{
        author_id: user.id,
        body: "Test body",
        conversation_id: conversation.id
      }

      {:ok, %ConversationPart{} = conversation_part} = Messages.add_part(attrs)

      conversation_part =
        conversation_part
        |> Repo.preload([:author, conversation: [message: [[project: :organization]]]])

      assert conversation_part.author_id == user.id
      assert conversation_part.body == "Test body"
      assert conversation_part.conversation_id == conversation.id
    end

    test "broadcasts event on phoenix channel" do
      conversation = insert(:conversation)
      user = insert(:user)
      attrs = %{
        author_id: user.id,
        body: "Test body",
        conversation_id: conversation.id
      }

      CodeCorpsWeb.Endpoint.subscribe("conversation:#{conversation.id}")
      {:ok, %ConversationPart{id: id}} = Messages.add_part(attrs)
      assert_broadcast("new:conversation-part", %{id: ^id})
      CodeCorpsWeb.Endpoint.unsubscribe("conversation:#{conversation.id}")
    end

    test "when replied by project admin, sends appropriate email to other participants" do
      part_author = insert(:user)
      %{author: message_author} = message = insert(:message)
      %{user: target_user} = conversation = insert(:conversation, message: message)
      %{author: other_participant} = insert(:conversation_part, conversation: conversation)

      attrs = %{
        author_id: part_author.id,
        body: "Test body",
        conversation_id: conversation.id
      }

      {:ok, %ConversationPart{} = part} = Messages.add_part(attrs)

      part = part |> Repo.preload([:author, conversation: [message: [[project: :organization]]]])

      part_author_email = ReplyToConversation.build(part, part_author)
      target_user_email = ReplyToConversation.build(part, target_user)
      message_author_email = ReplyToConversation.build(part, message_author)
      other_participant_email = ReplyToConversation.build(part, other_participant)
      refute_received ^part_author_email
      assert_received ^target_user_email
      assert_received ^message_author_email
      assert_received ^other_participant_email
    end

    test "when replied by conversation user, sends appropriate email to other participants" do
      part_author = insert(:user)
      %{author: message_author} = message = insert(:message)
      %{user: target_user} = conversation = insert(:conversation, message: message)
      %{author: other_participant} = insert(:conversation_part, conversation: conversation)

      attrs = %{
        author_id: part_author.id,
        body: "Test body",
        conversation_id: conversation.id
      }

      {:ok, %ConversationPart{} = part} = Messages.add_part(attrs)

      part = part |> Repo.preload([:author, conversation: [message: [[project: :organization]]]])

      part_author_email = ReplyToConversation.build(part, part_author)
      target_user_email = ReplyToConversation.build(part, target_user)
      message_author_email = ReplyToConversation.build(part, message_author)
      other_participant_email = ReplyToConversation.build(part, other_participant)
      refute_received ^part_author_email
      assert_received ^target_user_email
      assert_received ^message_author_email
      assert_received ^other_participant_email
    end
  end

  describe "create/1" do
    test "creates a message" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      params = %{
        author_id: user.id,
        body: "Foo",
        initiated_by: "admin",
        project_id: project.id,
        subject: "Bar"
      }

      {:ok, %Message{} = message} = params |> Messages.create

      assert message |> Map.take(params |> Map.keys) == params
    end

    test "creates a conversation if attributes are provided" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      recipient = insert(:user)
      params = %{
        author_id: user.id,
        body: "Foo",
        conversations: [%{user_id: recipient.id}],
        initiated_by: "admin",
        project_id: project.id,
        subject: "Bar"
      }

      {:ok, %Message{} = message} = params |> Messages.create

      assert message |> Map.take(params |> Map.delete(:conversations) |> Map.keys) == params |> Map.delete(:conversations)
      assert Conversation |> Repo.get_by(message_id: message.id, status: "open", user_id: recipient.id)
    end

    test "requires author_id, body, initiated_by, project_id" do
      {:error, %Changeset{} = changeset} = %{} |> Messages.create

      assert changeset.errors[:author_id]
      assert changeset.errors[:body]
      assert changeset.errors[:initiated_by]
      assert changeset.errors[:project_id]
    end

    test "requires subject if initiated by admin" do
      {:error, %Changeset{} = changeset} =
         %{initiated_by: "admin"} |> Messages.create

      assert changeset.errors[:subject]
    end

    test "allows blank subject if initiated by user" do
      {:error, %Changeset{} = changeset} =
         %{initiated_by: "user"} |> Messages.create

      refute changeset.errors[:subject]
    end

    test "fails on project validation if id invalid" do
      user = insert(:user)
      params = %{
        author_id: user.id,
        body: "Foo",
        initiated_by: "admin",
        project_id: 1,
        subject: "Bar"
      }

      {:error, %Changeset{} = changeset} = params |> Messages.create

      assert changeset.errors[:project]
    end

    test "fails on user validation if id invalid" do
      project = insert(:project)
      params = %{
        author_id: -1,
        body: "Foo",
        initiated_by: "admin",
        project_id: project.id,
        subject: "Bar"
      }

      {:error, %Changeset{} = changeset} = params |> Messages.create

      assert changeset.errors[:author]
    end

    test "requires conversation user_id" do
      params = %{conversations: [%{}]}
      {:error, %Changeset{} = changeset} = params |> Messages.create
      conversation_changeset = changeset.changes.conversations |> List.first

      assert conversation_changeset.errors[:user_id]
    end

    test "fails on conversation user validation if id invalid" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      params = %{
        author_id: user.id,
        body: "Foo",
        conversations: [%{user_id: -1}],
        initiated_by: "admin",
        project_id: project.id,
        subject: "Bar"
      }

      {:error, %Changeset{} = changeset} = params |> Messages.create
      conversation_changeset = changeset.changes.conversations |> List.first
      assert conversation_changeset.errors[:user]
    end

    test "when initiated by admin, sends email to each conversation user" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      [recipient_1, recipient_2] = insert_pair(:user)

      params = %{
        author_id: user.id,
        body: "Foo",
        conversations: [%{user_id: recipient_1.id}, %{user_id: recipient_2.id}],
        initiated_by: "admin",
        project_id: project.id,
        subject: "Bar"
      }

      {:ok, %Message{} = message} = params |> Messages.create
      %{conversations: [conversation_1, conversation_2]} = message =
        message |> Repo.preload([:project, [conversations: :user]])

      email_1 = MessageInitiatedByProject.build(message, conversation_1)
      assert_received ^email_1
      email_2 = MessageInitiatedByProject.build(message, conversation_2)
      assert_received ^email_2
    end
  end
end
