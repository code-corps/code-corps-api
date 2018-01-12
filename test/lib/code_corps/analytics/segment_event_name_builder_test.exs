defmodule CodeCorps.Analytics.SegmentEventNameBuilderTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.Factories

  alias CodeCorps.Analytics.SegmentEventNameBuilder

  describe "get_action_name/2" do
    test "with comment" do
      assert SegmentEventNameBuilder.build("1", :create, build(:comment)) == "Created Comment"
      assert SegmentEventNameBuilder.build("1", :update, build(:comment)) == "Edited Comment"
    end

    test "with task" do
      assert SegmentEventNameBuilder.build("1", :create, build(:task)) == "Created Task"
      assert SegmentEventNameBuilder.build("1", :update, build(:task)) == "Edited Task"
    end

    test "with user" do
      assert SegmentEventNameBuilder.build("1", :create, build(:user)) == "Signed Up"
    end

    test "with user category" do
      assert SegmentEventNameBuilder.build("1", :create, build(:user_category)) == "Added User Category"
      assert SegmentEventNameBuilder.build("1", :delete, build(:user_category)) == "Removed User Category"
    end

    test "with user role" do
      assert SegmentEventNameBuilder.build("1", :create, build(:user_role)) == "Added User Role"
      assert SegmentEventNameBuilder.build("1", :delete, build(:user_role)) == "Removed User Role"
    end

    test "with user skill" do
      assert SegmentEventNameBuilder.build("1", :create, build(:user_skill)) == "Added User Skill"
      assert SegmentEventNameBuilder.build("1", :delete, build(:user_skill)) == "Removed User Skill"
    end
  end
end
