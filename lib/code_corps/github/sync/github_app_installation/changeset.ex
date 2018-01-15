defmodule CodeCorps.GitHub.Sync.GithubAppInstallation.Changeset do
  @moduledoc ~S"""
  In charge of managing changesets when creating or updating a
  `GithubAppInstallation` in the process of handling an Installation event.
  """

  alias CodeCorps.{
    GitHub.Adapters,
    GithubAppInstallation,
    User
  }
  alias Ecto.Changeset

  @doc ~S"""
  Builds a changeset to create a `GithubAppInstallation` based on the payload
  from an Installation event.

  An optional user to associate the installation with can be provided.
  """
  @spec create_changeset(map, User.t | nil) :: Changeset.t
  def create_changeset(%{} = params, user \\ nil) do
    attrs = params |> Adapters.AppInstallation.from_installation_event()

    %GithubAppInstallation{}
    |> Changeset.change(attrs)
    |> Changeset.put_change(:installed, true)
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_change(:origin, "github")
    |> Changeset.unique_constraint(
      :github_id, name: :github_app_installations_github_id_index
    )
  end

  @doc ~S"""
  Builds a changeset to update a `GithubAppInstallation` based on the payload
  from an Installation event.
  """
  @spec update_changeset(GithubAppInstallation.t, map) :: Changeset.t
  def update_changeset(%GithubAppInstallation{} = record, %{} = params) do
    attrs = params |> Adapters.AppInstallation.from_installation_event()

    record
    |> Changeset.change(attrs)
    |> Changeset.put_change(:installed, true)
    |> Changeset.unique_constraint(
      :github_id, name: :github_app_installations_github_id_index
    )
  end
end
