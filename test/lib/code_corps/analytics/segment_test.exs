defmodule CodeCorps.Analytics.SegmentTest do
  use ExUnit.Case, async: true

  import CodeCorps.Analytics.Segment, only: [get_event_name: 2]
  import CodeCorps.Factories

  describe "get_action_name/2" do
    test "with comment" do
      assert get_event_name(:created, build(:comment)) == "Created Comment"
      assert get_event_name(:edited, build(:comment)) == "Edited Comment"
    end

    test "with organization membership" do
      assert get_event_name(:created, build(:organization_membership)) == "Requested Organization Membership"
      assert get_event_name(:edited, build(:organization_membership)) == "Approved Organization Membership"
    end

    test "with task" do
      assert get_event_name(:created, build(:task)) == "Created Task"
      assert get_event_name(:edited, build(:task)) == "Edited Task"
    end

    test "with user" do
      assert get_event_name(:signed_up, build(:user)) == "Signed Up"
    end

    test "with user category" do
      assert get_event_name(:created, build(:user_category)) == "Added User Category"
      assert get_event_name(:deleted, build(:user_category)) == "Removed User Category"
    end

    test "with user role" do
      assert get_event_name(:created, build(:user_role)) == "Added User Role"
      assert get_event_name(:deleted, build(:user_role)) == "Removed User Role"
    end

    test "with user skill" do
      assert get_event_name(:created, build(:user_skill)) == "Added User Skill"
      assert get_event_name(:deleted, build(:user_skill)) == "Removed User Skill"
    end
  end
end
