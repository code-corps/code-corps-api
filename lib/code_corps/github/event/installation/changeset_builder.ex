defmodule CodeCorps.GitHub.Event.Installation.ChangesetBuilder do
  @moduledoc ~S"""
  In charge of managing changesets when creating or updating a
  `GithubAppInstallation` in the process of handling an Installation event.
  """

  alias CodeCorps.{
    GithubAppInstallation,
    User
  }
  alias CodeCorps.GitHub.Adapters.GithubAppInstallation, as: GithubAppInstallationAdapter
  alias Ecto.Changeset

  @doc """
  Builds a changeset for a `GithubAppInstallation` based on the payload from
  an Installation event.
  """
  @spec build_changeset(GithubAppInstallation.t, map) :: Changeset.t
  def build_changeset(
    %GithubAppInstallation{} = github_app_installation,
    %{} = payload) do

    attrs = GithubAppInstallationAdapter.from_installation_event(payload)

    github_app_installation
    |> Changeset.change(attrs)
    |> Changeset.put_change(:installed, true)
    |> inferr_origin()
    |> Changeset.unique_constraint(:github_id, name: :github_app_installations_github_id_index)
  end

  @doc """
  Builds a changeset for a `GithubAppInstallation` based on the payload from
  an Installation event.

  Associates with provided user.
  """
  @spec build_changeset(GithubAppInstallation.t, map, User.t) :: Changeset.t
  def build_changeset(
    %GithubAppInstallation{} = github_app_installation,
    %{} = payload,
    %User{id: user_id}) do

    github_app_installation
    |> build_changeset(payload)
    |> Changeset.put_change(:user_id, user_id)
    |> Changeset.assoc_constraint(:user)
  end

  @spec inferr_origin(Changeset.t) :: Changeset.t
  defp inferr_origin(%Changeset{
    data: %GithubAppInstallation{id: nil}} = changeset) do

    changeset
    |> Changeset.put_change(:origin, "github")
  end
  defp inferr_origin(%Changeset{} = changeset), do: changeset
end
