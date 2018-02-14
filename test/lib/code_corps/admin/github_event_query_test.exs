defmodule CodeCorps.Admin.GithubEventQueryTest do
  @moduledoc false

  use CodeCorps.DbAccessCase

  alias CodeCorps.{
    Admin.GithubEventQuery,
    GithubEvent,
    Repo
  }

  describe "action_filter/2" do
    test "when action is present it filters" do
      created_event = insert(:github_event, action: "created")
      insert(:github_event, action: "opened")

      [result] =
        GithubEvent
        |> GithubEventQuery.action_filter(%{"action" => "created"})
        |> Repo.all()

      assert created_event == result
    end

    test "when action is not present returns the queryable" do
      created_event = insert(:github_event, action: "created")
      opened_event = insert(:github_event, action: "opened")

      [result1, result2] =
        GithubEvent
        |> GithubEventQuery.action_filter(%{})
        |> Repo.all()

      assert created_event == result1
      assert opened_event == result2
    end
  end

  describe "status_filter/2" do
    test "when status is present it filters" do
      processed_event = insert(:github_event, status: "processed")
      insert(:github_event, status: "unprocessed")

      [result] =
        GithubEvent
        |> GithubEventQuery.status_filter(%{"status" => "processed"})
        |> Repo.all()

      assert processed_event == result
    end

    test "when status is not present returns the queryable" do
      processed_event = insert(:github_event, status: "processed")
      unprocessed_event = insert(:github_event, status: "unprocessed")

      [result1, result2] =
        GithubEvent
        |> GithubEventQuery.status_filter(%{})
        |> Repo.all()

      assert processed_event == result1
      assert unprocessed_event == result2
    end
  end

  describe "type_filter/2" do
    test "when type is present it filters" do
      created_event = insert(:github_event, type: "issues")
      insert(:github_event, type: "installation")

      [result] =
        GithubEvent
        |> GithubEventQuery.type_filter(%{"type" => "issues"})
        |> Repo.all()

      assert created_event == result
    end

    test "when type is not present returns the queryable" do
      issues_event = insert(:github_event, type: "issues")
      installation_event = insert(:github_event, type: "installation")

      [result1, result2] =
        GithubEvent
        |> GithubEventQuery.type_filter(%{})
        |> Repo.all()

      assert issues_event == result1
      assert installation_event == result2
    end
  end
end
