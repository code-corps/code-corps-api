defmodule CodeCorps.GitHub.EventTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  import CodeCorps.Factories

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

  @ok_tuple {:ok, "foo"}
  @error_tuple {:error, "bar"}

  describe "stop_processing/2" do
    test "sets event status to 'processed' if ok tuple is the first argument" do
      event = insert(:github_event, status: "processing")
      {:ok, %GithubEvent{} = updated_event} = Event.stop_processing(@ok_tuple, event)
      assert updated_event.status == "processed"
    end

    test "sets event status to 'errored' if error tuple is the first argument" do
      event = insert(:github_event, status: "processing")
      {:ok, %GithubEvent{} = updated_event} = Event.stop_processing(@error_tuple, event)
      assert updated_event.status == "errored"
    end
  end
end
