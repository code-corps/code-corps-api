defmodule CodeCorps.GitHub.Adapters.TaskTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, Task}

  describe "from_api/1" do
    test "maps api payload correctly" do
      %{"issue" => payload} = load_event_fixture("issues_opened")

      assert Adapters.Task.from_api(payload) == %{
        created_at: payload["created_at"],
        github_issue_number: payload["number"],
        markdown: payload["body"],
        modified_at: payload["updated_at"],
        title: payload["title"],
        status: payload["state"]
      }
    end
  end

  describe "to_api/1" do
    test "maps Task correctly" do
      payload =
        %Task{number: 5, title: "Foo", markdown: "bar", status: "open"}
        |> Adapters.Task.to_api

      assert payload["body"] == "bar"
      assert payload["state"] == "open"
      assert payload["title"] == "Foo"
      refute payload["created_at"]
      refute payload["number"]
      refute payload["updated_at"]
    end
  end
end
