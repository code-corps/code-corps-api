defmodule CodeCorps.Policy.PreviewTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Preview, only: [create?: 2]

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)

      params = %{"markdown" => "markdown", "user_id" => user.id}
      assert create?(user, params)
    end

    test "returns false if user is creating someone else's record" do
      [user, another_user] = insert_pair(:user)
      params = %{"markdown" => "markdown", "user_id" => another_user.id}
      refute create?(user, params)
    end
  end
end
