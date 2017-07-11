defmodule CodeCorps.ProjectGithubRepoPolicy do
  import CodeCorps.Helpers.Policy, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{ProjectGithubRepo, User}
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> administered_by?(user)
  end

  def delete?(%User{} = user, %ProjectGithubRepo{} = project_github_repo) do
    project_github_repo |> get_project |> administered_by?(user)
  end
end
