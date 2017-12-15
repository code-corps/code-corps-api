defmodule CodeCorps.Messages.ConversationPartsTest do
  use CodeCorps.ModelCase

  alias CodeCorps.{
    ConversationPart,
    Messages.ConversationParts,
    Repo
  }

  @valid_attrs %{
    body: "Test body."
  }

  describe "create_changeset/2" do
    test "with valid attributes" do
      attrs = @valid_attrs |> Map.merge(%{author_id: 1, conversation_id: 1})
      changeset = ConversationParts.create_changeset(%ConversationPart{}, attrs)
      assert changeset.valid?
    end

    test "requires author_id" do
      conversation_id = insert(:conversation).id

      changeset = ConversationParts.create_changeset(%ConversationPart{}, %{conversation_id: conversation_id})

      refute changeset.valid?
      assert_error_message(changeset, :author_id, "can't be blank")
    end

    test "requires conversation_id" do
      author_id = insert(:user).id

      changeset = ConversationParts.create_changeset(%ConversationPart{}, %{author_id: author_id})

      refute changeset.valid?
      assert_error_message(changeset, :conversation_id, "can't be blank")
    end

    test "requires id of actual author" do
      author_id = -1
      conversation_id = insert(:conversation).id
      attrs = @valid_attrs |> Map.merge(%{author_id: author_id, conversation_id: conversation_id})

      {result, changeset} =
        ConversationParts.create_changeset(%ConversationPart{}, attrs)
        |> Repo.insert()

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :author, "does not exist")
    end

    test "requires id of actual conversation" do
      author_id = insert(:user).id
      conversation_id = -1
      attrs = @valid_attrs |> Map.merge(%{author_id: author_id, conversation_id: conversation_id})

      {result, changeset} =
        ConversationParts.create_changeset(%ConversationPart{}, attrs)
        |> Repo.insert()

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :conversation, "does not exist")
    end
  end
end
