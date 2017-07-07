defmodule CodeCorps.GitHub.Event.Installation.UnmatchedUser do
  @moduledoc """
  In charge of handling the unmatched user case of an installation event
  """

  alias CodeCorps.{
    GithubAppInstallation,
    Repo
  }

  alias Ecto.Changeset

  @doc """
  Handles the installation event in the case of an unmatched user.

  This is done by attempting to find a `GithubAppInstallation` record by it's
  `github_id` field.

  If a record is not found, which is the expected case, one is created and it's
  `sender_github_id` field is set, to be matched with a user which could later
  connect with github.

  If a record is found, the something must have went wrong at some point, since
  it should not happen, but the process continues gracefuly and simply updates
  the record (making no actual changes in most cases).
  """
  @spec handle(any, map) :: {:ok, GithubAppInstallation.t} | {:error, :unexpected_installation_payload}
  def handle(%{} = installation_attrs, %{} = sender_attrs) do
    case installation_attrs |> find_installation() do
      # There is no installation or user, we create an unmatched installation,
      # and store the sender_github_id on it, to match with a user which might
      # connect with github later
      nil -> create_installation(installation_attrs, sender_attrs)
      # We found an existing app installation matching the specified `github_id`.
      # This should really not happen, but we did, so we update, just in case.
      %GithubAppInstallation{} = installation -> update_installation(installation, installation_attrs, sender_attrs)
    end
  end

  @spec find_installation(any) :: GithubAppInstallation.t | nil
  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)
  defp find_installation(_), do: :unexpected_installation_payload

  @spec create_installation(map, map) :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  defp create_installation(%{} = installation_attrs, %{} = sender_attrs) do
    %GithubAppInstallation{}
    |> changeset(installation_attrs, sender_attrs)
    |> Repo.insert()
  end

  @spec update_installation(GithubAppInstallation.t, map, map) :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  defp update_installation(%GithubAppInstallation{} = installation, %{} = installation_attrs, %{} = sender_attrs) do
    installation
    |> changeset(installation_attrs, sender_attrs)
    |> Repo.update
  end

  @spec changeset(GithubAppInstallation.t, map, map) :: Changeset.t
  defp changeset(%GithubAppInstallation{} = installation, %{"id" => github_id}, %{"id" => sender_github_id}) do
    installation
    |> Changeset.change(%{github_id: github_id, sender_github_id: sender_github_id, installed: true, state: "unmatched_user"})
    |> Changeset.unique_constraint(:github_id, name: :github_app_installations_github_id_index)
  end
end
