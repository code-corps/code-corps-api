defmodule CodeCorps.GithubEventTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubEvent

  @valid_attrs %{
    action: "some content",
    github_delivery_id: "71aeab80-9e59-11e7-81ac-198364bececc",
    payload: %{"key" => "value"},
    status: "some content",
    type: "some content"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GithubEvent.changeset(%GithubEvent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GithubEvent.changeset(%GithubEvent{}, @invalid_attrs)
    refute changeset.valid?
  end
end
