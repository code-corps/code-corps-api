defmodule CodeCorps.Messages.ConversationQueryTest do
  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    Conversation,
    Messages.ConversationQuery,
    Repo
  }

  describe "status_filter/2" do
    test "filters by status" do
      open_conversation = insert(:conversation, status: "open")
      _closed_conversation = insert(:conversation, status: "closed")

      [result] =
        Conversation
        |> ConversationQuery.status_filter(%{"status" => "open"})
        |> Repo.all()

      assert result.id == open_conversation.id
    end
  end
end
