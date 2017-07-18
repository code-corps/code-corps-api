defmodule CodeCorps.GitHub.Event.Issues.StateMapperTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Event.Issues.StateMapper

  describe "get_state/1" do
    test "returns correct state for any supported Issues event fixture" do
      assert "issues_opened" |> load_event_fixture() |> StateMapper.get_state == "published"
      assert "issues_closed" |> load_event_fixture() |> StateMapper.get_state == "edited"
      assert "issues_edited" |> load_event_fixture() |> StateMapper.get_state == "edited"
      assert "issues_reopened" |> load_event_fixture() |> StateMapper.get_state == "edited"
    end
  end
end
