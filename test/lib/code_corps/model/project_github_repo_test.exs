defmodule CodeCorps.ProjectGithubRepoTest do
  use CodeCorps.ModelCase

  alias CodeCorps.ProjectGithubRepo

  describe "create_changeset/2" do
    test "with valid attributes" do
      project_id = insert(:project).id
      github_repo_id = insert(:github_repo).id

      changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id, github_repo_id: github_repo_id})
      assert changeset.valid?
    end

    test "requires project_id" do
      github_repo_id = insert(:github_repo).id

      changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{github_repo_id: github_repo_id})

      refute changeset.valid?
      assert_error_message(changeset, :project_id, "can't be blank")
    end


    test "requires github_repo_id" do
      project_id = insert(:project).id

      changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id})

      refute changeset.valid?
      assert_error_message(changeset, :github_repo_id, "can't be blank")
    end

    test "requires id of actual project" do
      project_id = -1
      github_repo_id = insert(:github_repo).id

      {result, changeset} =
        ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id, github_repo_id: github_repo_id})
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :project, "does not exist")
    end

    test "ensures uniqueness for github repo" do
      project = insert(:project)
      github_repo = insert(:github_repo)
      insert(:project_github_repo, project: project, github_repo: github_repo)

      {result, changeset} =
        ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project.id, github_repo_id: github_repo.id})
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :github_repo, "has already been taken")
    end

    test "requires id of actual github_repo" do
      project_id = insert(:project).id
      github_repo_id = -1

      {result, changeset} =
        ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id, github_repo_id: github_repo_id})
        |> Repo.insert

      assert result == :error
      refute changeset.valid?
      assert_error_message(changeset, :github_repo, "does not exist")
    end
  end

  describe "update_sync_changeset/2" do
    test "with valid attributes" do
      project_id = insert(:project).id
      github_repo_id = insert(:github_repo).id
      attrs = %{project_id: project_id, github_repo_id: github_repo_id}

      ProjectGithubRepo.sync_states |> Enum.each(fn state ->
        attrs =
          attrs
          |> Map.put(:sync_state, state)

        changeset = ProjectGithubRepo.update_sync_changeset(%ProjectGithubRepo{}, attrs)
        assert changeset.valid?
      end)
    end

    test "with invalid attributes" do
      project_id = insert(:project).id
      github_repo_id = insert(:github_repo).id
      attrs =
        %{project_id: project_id, github_repo_id: github_repo_id}
        |> Map.put(:sync_state, "not_a_valid_sync_state")

      changeset = ProjectGithubRepo.update_sync_changeset(%ProjectGithubRepo{}, attrs)
      refute changeset.valid?
      assert changeset.errors[:sync_state] == {"is invalid", [validation: :inclusion]}
    end
  end
end
