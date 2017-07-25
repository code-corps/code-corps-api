defmodule CodeCorps.GitHub.Event.Installation.UnmatchedUser do
  @moduledoc """
  In charge of handling the unmatched user case of an installation event
  """

  alias CodeCorps.{
    GitHub.Event.Installation.ChangesetBuilder,
    GithubAppInstallation,
    Repo
  }

  @typep process_outcome :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  @typep outcome :: process_outcome |  {:error, :unexpected_installation_payload}

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
  @spec handle(map) :: outcome
  def handle(%{"installation" => installation_attrs} = payload) do
    case installation_attrs |> find_installation() do
      nil -> create_installation(payload)
      :unexpected_installation_payload -> {:error, :unexpected_installation_payload}
      %GithubAppInstallation{} = installation -> update_installation(installation, payload)
    end
  end

  @spec find_installation(any) :: GithubAppInstallation.t | nil | :unexpected_installation_payload
  defp find_installation(%{"id" => github_id}) do
    GithubAppInstallation |> Repo.get_by(github_id: github_id)
  end
  defp find_installation(_), do: :unexpected_installation_payload

  @spec create_installation(map) :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  defp create_installation(%{} = payload) do
    %GithubAppInstallation{}
    |> ChangesetBuilder.build_changeset(payload)
    |> Repo.insert()
  end

  @spec update_installation(GithubAppInstallation.t, map) :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  defp update_installation(%GithubAppInstallation{} = installation, %{} = payload) do
    installation
    |> ChangesetBuilder.build_changeset(payload)
    |> Repo.update()
  end
end
