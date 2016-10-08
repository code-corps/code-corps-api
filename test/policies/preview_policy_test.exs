defmodule CodeCorps.PreviewPolicyTest do
  use CodeCorps.PolicyCase

  import CodeCorps.PreviewPolicy, only: [create?: 2]
  import CodeCorps.Preview, only: [create_changeset: 2]

  alias CodeCorps.Preview

  describe "create?" do
    test "returns true if user is creating their own record" do
      user = insert(:user)
      changeset = %Preview{} |> create_changeset(%{markdown: "markdown", user_id: user.id})
      assert create?(user, changeset)
    end

    test "returns false if user is creating someone else's record" do
      [user, another_user] = insert_pair(:user)
      changeset = %Preview{} |> create_changeset(%{markdown: "markdown", user_id: another_user.id})
      refute create?(user, changeset)
    end
  end
end
