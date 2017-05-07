defmodule CodeCorps.GitHub.Adapters.TaskTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import CodeCorps.GitHub.TestHelpers

  alias CodeCorps.{GitHub.Adapters, Task}

  describe "from_issue/1" do
    test "maps api payload correctly" do
      %{"issue" => payload} = load_event_fixture("issues_opened")

      assert Adapters.Task.from_issue(payload) == %{
        github_issue_number: payload["number"],
        title: payload["title"],
        markdown: payload["body"],
        status: payload["state"]
      }
    end
  end

  describe "to_issue/1" do
    test "maps Task correctly" do
      payload =
        %Task{number: 5, title: "Foo", markdown: "bar", status: "open"}
        |> Adapters.Task.to_issue

      assert payload["title"] == "Foo"
      assert payload["body"] == "bar"
      assert payload["state"] == "open"
      refute payload["number"]
    end
  end
end
