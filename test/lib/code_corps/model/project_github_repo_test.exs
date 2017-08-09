defmodule CodeCorps.ProjectGithubRepoTest do
  use CodeCorps.ModelCase

  alias CodeCorps.ProjectGithubRepo

  test "changeset with valid attributes" do
    project_id = insert(:project).id
    github_repo_id = insert(:github_repo).id

    changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id, github_repo_id: github_repo_id})
    assert changeset.valid?
  end

  test "changeset requires project_id" do
    github_repo_id = insert(:github_repo).id

    changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{github_repo_id: github_repo_id})

    refute changeset.valid?
    assert_error_message(changeset, :project_id, "can't be blank")
  end

  test "changeset requires github_repo_id" do
    project_id = insert(:project).id

    changeset = ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id})

    refute changeset.valid?
    assert_error_message(changeset, :github_repo_id, "can't be blank")
  end

  test "changeset requires id of actual project" do
    project_id = -1
    github_repo_id = insert(:github_repo).id

    {result, changeset} =
      ProjectGithubRepo.create_changeset(%ProjectGithubRepo{}, %{project_id: project_id, github_repo_id: github_repo_id})
      |> Repo.insert

    assert result == :error
    refute changeset.valid?
    assert_error_message(changeset, :project, "does not exist")
  end

  test "changeset requires id of actual github_repo" do
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
