defmodule CodeCorps.Transition.GithubAppInstallationStateTest do
  use ExUnit.Case, async: true

  alias CodeCorps.Transition.GithubAppInstallationState

  describe "next/2" do
    test "transitions from nil to initiated_on_code_corps" do
      assert GithubAppInstallationState.next(nil, "initiated_on_code_corps") == {:ok, "initiated_on_code_corps"}
    end

    test "returns {:ok, current} if next_state is nil" do
      assert GithubAppInstallationState.next("foo", nil) == {:ok, "foo"}
    end

    test "returns {:ok, next_state} for valid transitions" do
      assert GithubAppInstallationState.next("initiated_on_code_corps", "processing") == {:ok, "processing"}
      assert GithubAppInstallationState.next("initiated_on_code_corps", "processed") == {:ok, "processed"}
      assert GithubAppInstallationState.next("initiated_on_code_corps", "unmatched_user") == {:ok, "unmatched_user"}

      assert GithubAppInstallationState.next("processing", "processed") == {:ok, "processed"}
      assert GithubAppInstallationState.next("processing", "unmatched_user") == {:ok, "unmatched_user"}

      assert GithubAppInstallationState.next("unmatched_user", "processing") == {:ok, "processing"}
      assert GithubAppInstallationState.next("unmatched_user", "processed") == {:ok, "processed"}
    end

    test "returns {:ok, transition} for the current state" do
      assert GithubAppInstallationState.next("foo", "foo") == {:ok, "foo"}
    end

    test "returns {:error, message} for invalid transitions" do
      assert GithubAppInstallationState.next("foo", "bar") == {:error, "invalid transition to bar from foo"}
    end
  end
end
