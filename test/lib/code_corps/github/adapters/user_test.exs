defmodule CodeCorps.GitHub.Adapters.UserTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Adapters.User

  defp expected_payload(type) do
    %{
      email: nil,
      github_id: nil,
      github_username: nil,
      github_avatar_url: nil,
      type: type
    }
  end

  describe "to_user/1" do
    test "maps API payload" do
      %{"issue" => %{"user" => payload}} = load_event_fixture("issues_opened")

      assert User.to_user(payload) == %{
        email: nil,
        github_id: payload["id"],
        github_username: payload["login"],
        github_avatar_url: payload["avatar_url"],
        type: "user" # type gets transformed
      }
    end

    test "maps Bot type" do
      assert User.to_user(%{"type" => "Bot"}) == expected_payload("bot")
    end

    test "maps User type" do
      assert User.to_user(%{"type" => "User"}) == expected_payload("user")
    end

    test "maps Organization type" do
      assert User.to_user(%{"type" => "Organization"}) == expected_payload("organization")
    end
  end
end
