defmodule CodeCorps.Policy.GithubAppInstallation do
  @moduledoc """
  Handles `User` authorization of actions on `GithubAppInstallation` records
  """
  import CodeCorps.Policy.Helpers, only: [get_project: 1, owned_by?: 2]

  alias CodeCorps.{GithubAppInstallation, User}

  def create?(%User{} = user, params), do: params |> get_project |> owned_by?(user)

end
