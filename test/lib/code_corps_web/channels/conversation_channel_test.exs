defmodule CodeCorpsWeb.ConversationChannelTest do
  use CodeCorpsWeb.ChannelCase

  alias CodeCorps.{Conversation, User}
  alias CodeCorpsWeb.ConversationChannel

  def build_socket(%Conversation{id: id}, %User{} = current_user) do
    "test"
    |> socket(%{current_user: current_user})
    |> subscribe_and_join(ConversationChannel, "conversation:#{id}")
  end

  describe "conversation:id" do
    test "requires authentication" do
      %{id: id} = insert(:conversation)

      response =
        "test"
        |> socket(%{})
        |> subscribe_and_join(ConversationChannel, "conversation:#{id}")

      assert response == {:error, %{reason: "unauthenticated"}}
    end

    test "ensures current user is authorized for :show on resource" do
      user = insert(:user)
      %{id: id} = insert(:conversation)

      response =
        "test"
        |> socket(%{current_user: user})
        |> subscribe_and_join(ConversationChannel, "conversation:#{id}")

      assert response == {:error, %{reason: "unauthorized"}}
    end

    test "broadcasts new conversation part" do
      %{id: id, user: user} = conversation = insert(:conversation)

      {:ok, %{}, _socket} =
        "test"
        |> socket(%{current_user: user})
        |> subscribe_and_join(ConversationChannel, "conversation:#{id}")

      %{id: conversation_part_id} = conversation_part =
        insert(:conversation_part, conversation: conversation)
      ConversationChannel.broadcast_new_conversation_part(conversation_part)

      assert_broadcast("new:conversation-part", %{id: ^conversation_part_id})
    end
  end
end
