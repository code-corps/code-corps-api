defmodule CodeCorps.Analytics.SegmentEventNameBuilderTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.Factories

  alias CodeCorps.Analytics.SegmentEventNameBuilder

  describe "get_action_name/2" do
    test "with comment" do
      assert SegmentEventNameBuilder.build(:create, build(:comment)) == "Created Comment"
      assert SegmentEventNameBuilder.build(:update, build(:comment)) == "Edited Comment"
    end

    test "with organization membership" do
      assert SegmentEventNameBuilder.build(:create, build(:organization_membership)) == "Requested Organization Membership"
      assert SegmentEventNameBuilder.build(:update, build(:organization_membership)) == "Approved Organization Membership"
    end

    test "with task" do
      assert SegmentEventNameBuilder.build(:create, build(:task)) == "Created Task"
      assert SegmentEventNameBuilder.build(:update, build(:task)) == "Edited Task"
    end

    test "with user" do
      assert SegmentEventNameBuilder.build(:create, build(:user)) == "Signed Up"
    end

    test "with user category" do
      assert SegmentEventNameBuilder.build(:create, build(:user_category)) == "Added User Category"
      assert SegmentEventNameBuilder.build(:delete, build(:user_category)) == "Removed User Category"
    end

    test "with user role" do
      assert SegmentEventNameBuilder.build(:create, build(:user_role)) == "Added User Role"
      assert SegmentEventNameBuilder.build(:delete, build(:user_role)) == "Removed User Role"
    end

    test "with user skill" do
      assert SegmentEventNameBuilder.build(:create, build(:user_skill)) == "Added User Skill"
      assert SegmentEventNameBuilder.build(:delete, build(:user_skill)) == "Removed User Skill"
    end
  end
end
