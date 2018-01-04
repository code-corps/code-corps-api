defmodule CodeCorps.Analytics.SegmentDataExtractorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.Factories

  alias CodeCorps.Analytics.SegmentDataExtractor

  describe "get_project_id/1" do
    test "should return correct id for project user" do
      project_user = build(:project_user)
      project_id = "project_#{project_user.project_id}"

      assert SegmentDataExtractor.get_project_id(project_user) == project_id
    end

    test "should return nil for unknown resource" do
      assert SegmentDataExtractor.get_project_id(%{}) == nil
    end
  end

end
