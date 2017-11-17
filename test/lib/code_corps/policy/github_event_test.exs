defmodule CodeCorps.GithubEventPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.GithubEvent, only: [index?: 1, show?: 1, update?: 1]

  describe "index" do
    test "returns true when user is an admin" do
      user = build(:user, admin: true)
      assert index?(user)
    end

    test "returns false when user is not an admin" do
      user = build(:user, admin: false)
      refute index?(user)
    end
  end

  describe "show" do
    test "returns true when user is an admin" do
      user = insert(:user, admin: true)
      assert show?(user)
    end

    test "returns false when user is not an admin" do
      user = insert(:user, admin: false)
      refute show?(user)
    end
  end

  describe "update" do
    test "returns true when user is an admin" do
      user = insert(:user, admin: true)
      assert update?(user)
    end

    test "returns false when user is not an admin" do
      user = insert(:user, admin: false)
      refute update?(user)
    end
  end
end
