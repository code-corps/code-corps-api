defmodule CodeCorps.Policy.ProjectGithubRepo do
  import CodeCorps.Policy.Helpers, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{ProjectGithubRepo, User}

  @spec create?(User.t, map) :: boolean
  def create?(%User{} = user, %{} = params) do
    params |> get_project |> administered_by?(user)
  end

  @spec delete?(User.t, ProjectGithubRepo.t) :: boolean
  def delete?(%User{} = user, %ProjectGithubRepo{} = project_github_repo) do
    project_github_repo |> get_project |> administered_by?(user)
  end
end
