defmodule CodeCorps.GitHub.Event.Installation.MatchedUser do
  @moduledoc """
  In charge of handling the matched user case of an installation event
  """

  import Ecto.Query

  alias CodeCorps.{
    GitHub.Event.Installation.ChangesetBuilder,
    GithubAppInstallation,
    Repo,
    User
  }

  @typep process_outcome :: {:ok, GithubAppInstallation.t} | {:error, Changeset.t}
  @typep outcome :: process_outcome | {:error, :too_many_unprocessed_installations}

  @doc """
  Handles the installation event in the case of a matched user.

  This is done by attempting to find a `GithubAppInstallation` record belonging
  to the matched user, with a blank `github_id` field.

  If no records are found, this means the installation was done from GitHub
  directly and it just so happens we have a connected GitHub user on record
  who performed the installation.

  If a record is found, then we update it's `github_id` field and then fetch
  repositories for that installation and store them locally.

  The case of multiple records being found should not be possible and results
  in an error tuple being returned.
  """
  @spec handle(map, User.t) :: outcome
  def handle(%User{} = user, %{} = payload) do
    case user |> find_unprocessed_installations() do
      [] -> user |> create_installation(payload)
      [%GithubAppInstallation{} = installation] -> update_installation(installation, payload)
      [_|_] -> {:error, :too_many_unprocessed_installations}
    end
  end

  @spec find_unprocessed_installations(User.t) :: list(GithubAppInstallation.t)
  defp find_unprocessed_installations(%User{id: user_id}) do
    GithubAppInstallation
    |> where([i], is_nil(i.github_id) and i.user_id == ^user_id)
    |> preload(:github_repos)
    |> Repo.all
  end

  @spec create_installation(User.t, map) :: process_outcome
  defp create_installation(%User{} = user, %{} = payload) do
    %GithubAppInstallation{}
    |> ChangesetBuilder.build_changeset(payload, user)
    |> Repo.insert()
  end

  @spec update_installation(GithubAppInstallation.t, map) :: process_outcome
  defp update_installation(%GithubAppInstallation{} = installation, %{} = payload) do
    installation
    |> ChangesetBuilder.build_changeset(payload)
    |> Repo.update()
  end
end
