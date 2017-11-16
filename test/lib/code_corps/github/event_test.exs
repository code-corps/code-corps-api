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

  describe "stop_processing/2" do
    test "sets event as processed if resulting tuple starts with :ok" do
      event = insert(:github_event, status: "processing")
      {:ok, %GithubEvent{} = updated_event} = Event.stop_processing({:ok, "foo"}, event)
      assert updated_event.status == "processed"
    end

    test "marks event errored, with failure_reason, if resulting tuple starts with :error" do
      event = insert(:github_event, status: "processing")
      {:ok, %GithubEvent{} = updated_event} = Event.stop_processing({:error, :bar, %{}}, event)
      assert updated_event.status == "errored"
      assert updated_event.failure_reason == "bar"
    end
  end
end
