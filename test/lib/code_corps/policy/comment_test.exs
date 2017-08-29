defmodule CodeCorps.Policy.CommentTest do
  use CodeCorps.PolicyCase

  alias CodeCorps.{Comment, Policy, User}

  describe "create?" do
    test "returns true if own record" do
      user = insert(:user)
      params = %{"user_id" => user.id}
      assert Policy.Comment.create?(user, params)
    end

    test "returns false if someone else's record" do
      [user, another_user] = insert_pair(:user)
      params = %{"user_id" => another_user.id}
      refute Policy.Comment.create?(user, params)
    end

    test "returns false by default" do
      refute Policy.Comment.create?(%User{}, %{})
    end
  end

  describe "update?" do
    test "returns true if own record" do
      user = insert(:user)
      comment = insert(:comment, user: user)
      assert Policy.Comment.update?(user, comment)
    end

    test "returns false if someone else's record" do
      [user, another_user] = insert_pair(:user)
      comment = insert(:comment, user: user)
      refute Policy.Comment.update?(another_user, comment)
    end

    test "returns false by default" do
      refute Policy.Comment.update?(%User{}, %Comment{})
    end
  end
end
