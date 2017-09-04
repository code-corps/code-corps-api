defmodule CodeCorps.GitHub.EventTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    GithubEvent,
    GitHub.Event
  }

  describe "start_processing/1" do
    test "sets event status to processing" do
      event = insert(:github_event, status: "unprocessed")
      {:ok, %GithubEvent{} = updated_event} = Event.start_processing(event)
      assert updated_event.status == "processing"
    end
  end

  defp get_resulting_status(tuple) do
    event = insert(:github_event, status: "processing")
    {:ok, %GithubEvent{} = updated_event} = Event.stop_processing(tuple, event)
    updated_event.status
  end

  describe "stop_processing/2" do
    test "sets proper status for event, based on first argument" do
      assert {:ok} |> get_resulting_status() == "processed"
      assert {:ok, "foo"} |> get_resulting_status() == "processed"
      assert {:ok, "foo", "bar"} |> get_resulting_status() == "processed"
      assert {:ok, "foo", "bar", "baz"} |> get_resulting_status() == "processed"
      assert {:error} |> get_resulting_status() == "errored"
      assert {:error, "foo"} |> get_resulting_status() == "errored"
      assert {:error, "foo", "bar"} |> get_resulting_status() == "errored"
      assert {:error, "foo", "bar", "baz"} |> get_resulting_status() == "errored"
    end
  end
end
