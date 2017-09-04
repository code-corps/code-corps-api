defmodule CodeCorps.GitHub.Event.Issues.ValidatorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Event.Issues.Validator

  describe "valid?/1" do
    test "returns true for any Issues event fixture" do
      assert "issues_opened" |> load_event_fixture() |> Validator.valid?
      assert "issues_closed" |> load_event_fixture() |> Validator.valid?
      assert "issues_edited" |> load_event_fixture() |> Validator.valid?
      assert "issues_reopened" |> load_event_fixture() |> Validator.valid?
    end

    test "returns false for an unsupported structure" do
      refute Validator.valid?("foo")
      refute Validator.valid?(%{"foo" => "bar"})
      refute Validator.valid?(%{"issue" => %{"bar" => "baz"}})
    end
  end
end
