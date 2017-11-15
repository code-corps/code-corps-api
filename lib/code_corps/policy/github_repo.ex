defmodule CodeCorps.Policy.GithubRepo do
  @moduledoc """
  Handles `User` authorization of actions on `GithubRepo` records
  """
  import CodeCorps.Policy.Helpers, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.{GithubAppInstallation, GithubRepo, User}

  def update?(%User{} = user, %GithubRepo{project_id: nil}, %{"project_id" => _} = params) do
    params |> get_project |> administered_by?(user)
  end
  def update?(%User{} = user, %GithubRepo{} = github_repo, %{}) do
    github_repo |> get_project |> administered_by?(user)
  end
end
