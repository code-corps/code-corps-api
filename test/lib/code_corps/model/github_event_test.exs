defmodule CodeCorps.GithubEventTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubEvent

  @valid_attrs %{
    action: "some content",
    github_delivery_id: "71aeab80-9e59-11e7-81ac-198364bececc",
    payload: %{"key" => "value"},
    status: "processing",
    type: "some content"
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = GithubEvent.changeset(%GithubEvent{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = GithubEvent.changeset(%GithubEvent{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "validates inclusion of status" do
      attrs = @valid_attrs |> Map.put(:status, "foo")
      changeset = GithubEvent.changeset(%GithubEvent{}, attrs)
      refute changeset.valid?
      assert changeset.errors[:status] == {"is invalid", [validation: :inclusion]}
    end
  end

  describe "update_changeset/2" do
    test "with retry true and status errored" do
      attrs = @valid_attrs |> Map.merge(%{retry: true, status: "errored"})
      changeset = GithubEvent.update_changeset(%GithubEvent{status: "errored"}, attrs)
      assert changeset.valid?
      assert changeset.changes[:status] == "reprocessing"
    end

    test "with retry true and status not errored" do
      attrs = @valid_attrs |> Map.put(:retry, true)
      changeset = GithubEvent.update_changeset(%GithubEvent{status: "foo"}, attrs)
      refute changeset.valid?
      assert_error_message(changeset, :retry, "only possible when status is errored")
    end

    test "with retry false" do
      attrs = @valid_attrs |> Map.put(:retry, false)
      changeset = GithubEvent.update_changeset(%GithubEvent{}, attrs)
      refute changeset.valid?
      refute changeset.changes[:status] == "reprocessing"
    end
  end
end
