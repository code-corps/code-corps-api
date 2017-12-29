defmodule CodeCorps.GitHub.EventTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    GithubEvent,
    GitHub.APIError,
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

    test "marks event errored for changeset" do
      event = insert(:github_event, status: "processing")
      data = %{foo: "bar"}
      changeset = %Ecto.Changeset{data: data}

      {:ok, %GithubEvent{} = updated_event} =
        {:error, :bar, changeset}
        |> Event.stop_processing(event)

      assert updated_event.data == data |> Kernel.inspect(pretty: true)
      assert updated_event.error == changeset |> Kernel.inspect(pretty: true)
      assert updated_event.failure_reason == "bar"
      assert updated_event.status == "errored"
    end

    test "marks event errored for API error" do
      event = insert(:github_event, status: "processing")
      error_body = %{"message" => "bar"}
      error_code = 401
      error = APIError.new({error_code, error_body})

      {:ok, %GithubEvent{} = updated_event} =
        {:error, :bar, error}
        |> Event.stop_processing(event)

      assert updated_event.data == nil
      assert updated_event.error == error |> Kernel.inspect(pretty: true)
      assert updated_event.failure_reason == "bar"
      assert updated_event.status == "errored"
    end
  end
end
