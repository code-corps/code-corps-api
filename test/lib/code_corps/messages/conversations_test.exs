defmodule CodeCorps.Messages.ConversationsTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    Conversation, Messages
  }

  describe "part_added_changeset/1" do
    test "sets the updated_at to the current time" do
      old_updated_at = Timex.now |> Timex.shift(days: -5)
      conversation = %Conversation{updated_at: old_updated_at}
      changeset = conversation |> Messages.Conversations.part_added_changeset()
      assert changeset.changes[:updated_at] > old_updated_at
    end

    test "sets status to open" do
      conversation = %Conversation{status: "closed"}
      changeset = conversation |> Messages.Conversations.part_added_changeset()
      assert changeset.changes[:status] == "open"
    end
  end
end
