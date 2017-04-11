defmodule CodeCorps.Web.UserPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Web.UserPolicy, only: [update?: 2]

  describe "update?" do
    test "returns true if user is updating their own record" do
      user = insert(:user)
      assert update?(user, user) 
    end

    test "returns false if user is updating someone else's record" do
      [user, another_user] = insert_pair(:user)
      refute update?(another_user, user)
    end
  end
end
