defmodule CodeCorps.Policy.OrganizationGithubAppInstallation do
  @moduledoc """
  Handles `User` authorization of actions on `OrganizationGithubAppInstallation` records
  """
  import CodeCorps.Policy.Helpers, only: [get_organization: 1, owned_by?: 2]

  alias CodeCorps.{OrganizationGithubAppInstallation, User}

  def create?(%User{} = user, %Ecto.Changeset{} = changeset),
    do: changeset |> get_organization |> owned_by?(user)

  def delete?(%User{} = user, %OrganizationGithubAppInstallation{} = github_app_installation),
    do: github_app_installation |> get_organization |> owned_by?(user)
end
