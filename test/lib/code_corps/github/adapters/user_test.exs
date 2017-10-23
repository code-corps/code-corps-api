defmodule CodeCorps.GitHub.Adapters.UserTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.GitHub.Adapters.User

  describe "from_github_user/1" do
    test "maps API payload" do
      %{"issue" => %{"user" => payload}} = load_event_fixture("issues_opened")

      assert User.from_github_user(payload) == %{
        github_id: payload["id"],
        github_username: payload["login"],
        github_avatar_url: payload["avatar_url"],
        type: "user" # type gets transformed
      }
    end

    test "maps Bot type" do
      assert User.from_github_user(%{"type" => "Bot"}) == %{type: "bot"}
    end

    test "maps User type" do
      assert User.from_github_user(%{"type" => "User"}) == %{type: "user"}
    end

    test "does not map Organization type" do
      assert User.from_github_user(%{"type" => "Organization"}) == %{type: "Organization"}
    end
  end
end
