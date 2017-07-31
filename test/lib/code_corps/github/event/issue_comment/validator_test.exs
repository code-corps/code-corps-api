defmodule CodeCorps.GitHub.Event.IssueComment.ValidatorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Event.IssueComment.Validator

  describe "valid?/1" do
    test "returns true for any Issues event fixture" do
      assert "issue_comment_created" |> load_event_fixture() |> Validator.valid?
      assert "issue_comment_deleted" |> load_event_fixture() |> Validator.valid?
      assert "issue_comment_edited" |> load_event_fixture() |> Validator.valid?
    end

    test "returns false for an unsupported structure" do
      refute Validator.valid?("foo")
      refute Validator.valid?(%{"foo" => "bar"})
      refute Validator.valid?(%{"issue" => %{"bar" => "baz"}})
    end
  end
end
