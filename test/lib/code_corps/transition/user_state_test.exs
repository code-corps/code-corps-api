defmodule CodeCorps.Transition.UserStateTest do
  use ExUnit.Case, async: true

  alias CodeCorps.Transition.UserState

  describe "next/2" do
    test "returns nil if state_transition is nil" do
      assert UserState.next("foo", nil) == nil
    end

    test "returns {:ok, next_state} for valid transitions" do
      assert UserState.next("signed_up", "edit_profile") == {:ok, "edited_profile"}

      assert UserState.next("edited_profile", "select_categories") == {:ok, "selected_categories"}
      assert UserState.next("edited_profile", "skip_categories") == {:ok, "skipped_categories"}

      assert UserState.next("selected_categories", "select_roles") == {:ok, "selected_roles"}
      assert UserState.next("selected_categories", "skip_roles") == {:ok, "skipped_roles"}

      assert UserState.next("skipped_categories", "select_roles") == {:ok, "selected_roles"}
      assert UserState.next("skipped_categories", "skip_roles") == {:ok, "skipped_roles"}

      assert UserState.next("selected_roles", "select_skills") == {:ok, "selected_skills"}
      assert UserState.next("selected_roles", "skip_skills") == {:ok, "skipped_skills"}

      assert UserState.next("skipped_roles", "select_skills") == {:ok, "selected_skills"}
      assert UserState.next("skipped_roles", "skip_skills") == {:ok, "skipped_skills"}
    end

    test "returns {:error, message} for invalid transitions" do
      assert UserState.next("foo", "bar") == {:error, "invalid transition bar from foo"}
    end
  end
end
