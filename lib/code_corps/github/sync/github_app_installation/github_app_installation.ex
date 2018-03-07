defmodule CodeCorps.GitHub.Sync.GithubAppInstallation do
  import Ecto.Query

  alias CodeCorps.{GithubAppInstallation, Analytics.SegmentTracker, GitHub.Sync, Repo, User}
  alias Ecto.Changeset

  @type commit_result ::
    {:ok, GithubAppInstallation.t()} | {:error, Changeset.t()}

  @type outcome ::
    commit_result() | {:error, :multiple_unprocessed_installations_found}

  @doc ~S"""
  Tries to sync a GithubAppInstallation record using a Github API payload.

  The process is branching.

  If the installation can be matched by github id, then it is simply updated.

  If the installation cannot be matched by github id, then the system tries to
  locate the user, through the sender github id.

  If that fails, an unassociated installation is created.

  If a user is found, the system looks for a "skeleton" installation. This is
  a `CodeCorps.GithubAppInstallation` record which was created from the project
  integration page, but the webhook for the next step, which is actually
  performing the installation on Github.com, has not yet been done.

  This "skeleton" record is associated to a project and a user, but does
  not have any github data yet.

  In this case, the system assumes a single "skeleton" installation. If multiple
  are found, an error tuple is returned.

  If an installation is matched this way, it gets updated.

  Finally, if no installation has been matched in this alternative way, an
  installation associated to a user, but not associated to a project gets
  created.
  """
  @spec sync(map) :: outcome()
  def sync(%{} = payload) do
    case payload |> find_installation() do
      %GithubAppInstallation{} = installation ->
        installation |> update_installation(payload)

      nil ->
        payload |> sync_unmatched(payload |> find_user())
    end
  end

  @spec sync_unmatched(map, User.t() | nil) ::
    commit_result() | {:error, :multiple_unprocessed_installations_found}
  defp sync_unmatched(%{} = payload, nil) do
    track_installed_from_github(nil, payload)

    payload |> create_installation()
  end
  defp sync_unmatched(%{} = payload, %User{} = user) do
    case user |> find_unprocessed_installations() do
      [] ->
        track_installed_from_github(user, payload)

        create_installation(payload, user)

      [%GithubAppInstallation{} = installation] ->
        update_installation(installation, payload)

      [_|_] ->
        {:error, :multiple_unprocessed_installations_found}
    end
  end

  @spec find_user(map) :: User.t() | nil
  defp find_user(%{"sender" => %{"id" => github_id}}) do
    Repo.get_by(User, github_id: github_id)
  end

  @spec find_installation(any) :: GithubAppInstallation.t() | nil
  defp find_installation(%{"installation" => %{"id" => github_id}}) do
    GithubAppInstallation |> Repo.get_by(github_id: github_id)
  end

  @spec find_unprocessed_installations(User.t()) ::
    list(GithubAppInstallation.t())
  defp find_unprocessed_installations(%User{id: user_id}) do
    GithubAppInstallation
    |> where([i], is_nil(i.github_id) and i.user_id == ^user_id)
    |> Repo.all()
  end

  @spec create_installation(map, User.t() | nil) :: commit_result()
  defp create_installation(%{} = payload, user \\ nil) do

    payload
    |> Sync.GithubAppInstallation.Changeset.create_changeset(user)
    |> Repo.insert()
  end

  @spec update_installation(GithubAppInstallation.t, map) :: commit_result()
  defp update_installation(%GithubAppInstallation{} = installation, %{} = payload) do
    installation
    |> Sync.GithubAppInstallation.Changeset.update_changeset(payload)
    |> Repo.update()
  end

  @spec track_installed_from_github(User.t | nil, map) :: any
  defp track_installed_from_github(%User{id: user_id}, %{"installation" => installation} = _payload) do
    user_id |> SegmentTracker.track("Installed from GitHub", struct(%GithubAppInstallation{}, installation))
  end

  defp track_installed_from_github(nil, %{"installation" => installation, "sender" => sender} = _payload) do
    sender["id"] |> SegmentTracker.track("Installed from github by anon user", struct(%GithubAppInstallation{}, installation))
  end
end
