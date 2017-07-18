defmodule CodeCorps.GitHub.Adapters.TaskTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.TestHelpers.GitHub

  alias CodeCorps.GitHub.Adapters.Task

  describe "from_issue/1" do
    test "maps api payload correctly" do
      %{"issue" => payload} = load_event_fixture("issues_opened")

      assert Task.from_issue(payload) == %{
        github_id: payload["id"],
        title: payload["title"],
        markdown: payload["body"],
        status: payload["state"]
      }
    end
  end
end
