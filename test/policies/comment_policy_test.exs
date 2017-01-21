defmodule CodeCorps.CommentPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.CommentPolicy, only: [create?: 2, update?: 2]
  import CodeCorps.Comment, only: [create_changeset: 2]

  alias CodeCorps.Comment

  describe "create?" do
    test "returns true if own record" do
      user = insert(:user)
      changeset = %Comment{} |> create_changeset(%{user_id: user.id})
      assert create?(user, changeset)
    end

    test "returns false if someone else's record" do
      [user, another_user] = insert_pair(:user)
      changeset = %Comment{} |> create_changeset(%{user_id: another_user.id})
      refute create?(user, changeset)
    end

    test "returns false if changeset is empty" do
      user = insert(:user)
      changeset = %Comment{} |> create_changeset(%{})
      refute create?(user, changeset)
    end
  end

  describe "update?" do
    test "returns true if own record" do
      user = insert(:user)
      comment = insert(:comment, user: user)
      assert update?(user, comment)
    end

    test "returns false if someone else's record" do
      [user, another_user] = insert_pair(:user)
      comment = insert(:comment, user: user)
      refute update?(another_user, comment)
    end
  end
end
