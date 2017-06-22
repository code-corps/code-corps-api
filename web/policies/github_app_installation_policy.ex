defmodule CodeCorps.GithubAppInstallationPolicy do
  @moduledoc """
  Handles `User` authorization of actions on `GithubAppInstallation` records
  """
  import CodeCorps.Helpers.Policy, only: [get_project: 1, owned_by?: 2]

  alias CodeCorps.{GithubAppInstallation, User}

  def create?(%User{} = user, %Ecto.Changeset{} = changeset),
    do: changeset |> get_project |> owned_by?(user)

  def update?(%User{} = user, %GithubAppInstallation{} = github_app_installation),
    do: github_app_installation |> get_project |> owned_by?(user)
end
