defmodule CodeCorps.GitHub.Event.PullRequest.ValidatorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Event.PullRequest.Validator

  describe "valid?/1" do
    test "returns true for any PullRequest event fixture" do
      assert "pull_request_opened" |> load_event_fixture() |> Validator.valid?
      assert "pull_request_closed" |> load_event_fixture() |> Validator.valid?
      assert "pull_request_edited" |> load_event_fixture() |> Validator.valid?
      assert "pull_request_reopened" |> load_event_fixture() |> Validator.valid?
    end

    test "returns false for an unsupported structure" do
      refute Validator.valid?("foo")
      refute Validator.valid?(%{"foo" => "bar"})
      refute Validator.valid?(%{"issue" => %{"bar" => "baz"}})
    end
  end
end
