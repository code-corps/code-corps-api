defmodule CodeCorps.MessageTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Message

  @valid_admin_initiated_attrs %{
    body: "Test body.",
    initiated_by: "admin",
    subject: "Test subject"
  }
  @valid_user_initiated_attrs %{
    body: "Test body.",
    initiated_by: "user"
  }
  @invalid_attrs %{}

  describe "changeset" do
    test "when initiated by an admin with valid attributes" do
      changeset = Message.changeset(%Message{}, @valid_admin_initiated_attrs)
      assert changeset.valid?
    end

    test "when initiated by an admin with invalid attributes" do
      changeset = Message.changeset(%Message{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "when initiated by a user with valid attributes" do
      changeset = Message.changeset(%Message{}, @valid_user_initiated_attrs)
      assert changeset.valid?
    end

    test "when initiated by a user with invalid attributes" do
      changeset = Message.changeset(%Message{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "when initiated by an unknown source" do
      attrs = %{body: "Test body.", initiated_by: "invalid"}
      changeset = Message.changeset(%Message{}, attrs)
      refute changeset.valid?
    end
  end
end
