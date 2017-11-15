defmodule CodeCorps.GithubRepoTest do
  use CodeCorps.ModelCase

  alias CodeCorps.GithubRepo

  @valid_attrs %{
    github_account_avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
    github_account_id: 6752317,
    github_account_login: "baxterthehacker",
    github_account_type: "User",
    github_id: 35129377,
    name: "public-repo",
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = GithubRepo.changeset(%GithubRepo{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = GithubRepo.changeset(%GithubRepo{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "update_changeset/2" do
    test "when project added" do
      attrs = @valid_attrs |> Map.put(:project_id, 1)
      changeset = GithubRepo.update_changeset(%GithubRepo{}, attrs)
      assert changeset.valid?
    end

    test "when project removed" do
      attrs = @valid_attrs |> Map.put(:project_id, nil)
      changeset = GithubRepo.update_changeset(%GithubRepo{sync_state: "synced"}, attrs)
      assert changeset.valid?
      assert changeset.changes[:sync_state] == "unsynced"
    end
  end

  describe "update_sync_changeset/2" do
    test "with valid attributes" do
      GithubRepo.sync_states |> Enum.each(fn state ->
        attrs = @valid_attrs |> Map.put(:sync_state, state)
        changeset = GithubRepo.update_sync_changeset(%GithubRepo{}, attrs)
        assert changeset.valid?
      end)
    end

    test "with invalid attributes" do
      attrs = @valid_attrs |> Map.put(:sync_state, "not_a_valid_sync_state")
      changeset = GithubRepo.update_sync_changeset(%GithubRepo{}, attrs)
      refute changeset.valid?
      assert changeset.errors[:sync_state] == {"is invalid", [validation: :inclusion]}
    end
  end
end
