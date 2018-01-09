defmodule CodeCorps.GitHub.Sync.Repo do
  import Ecto.Query

  alias CodeCorps.{
    GitHub.Adapters,
    GitHub.API.Installation,
    GitHub.Utils.ResultAggregator,
    GithubAppInstallation,
    GithubRepo,
    Repo
  }

  alias Ecto.{Changeset, Multi}

  @typep commit_result :: {:ok, GithubRepo.t()} | {:error, Changeset.t()}

  @typep aggregated_result ::
    {:ok, list(GithubRepo.t())} |
    {:error, {list(GithubRepo.t()), list(Changeset.t())}}

  @spec sync_installation(GithubAppInstallation.t(), map) :: aggregated_result()

  def sync_installation(
    %GithubAppInstallation{} = installation,
    %{"action" => "added", "repositories_added" => repositories}) do

    do_sync_installation(installation, [], repositories)
  end

  def sync_installation(
    %GithubAppInstallation{} = installation,
    %{"action" => "removed", "repositories_removed" => repositories}) do

    github_ids = repositories |> Enum.map(&Map.get(&1, "id"))
    do_sync_installation(installation, github_ids, [])
  end

  @spec sync_installation(GithubAppInstallation.t()) ::
    aggregated_result() | {:error, struct}
  def sync_installation(%GithubAppInstallation{} = installation) do
    with {:ok, payloads} <- installation |> Installation.repositories() do
      %GithubAppInstallation{github_repos: repos} = installation =
        installation |> Repo.preload(:github_repos)

      master_id_list = payloads |> Enum.map(&Map.get(&1, "id"))
      ids_to_delete =
        repos
        |> Enum.filter(fn repo -> not(repo.github_id in master_id_list) end)
        |> Enum.map(&Map.get(&1, :github_id))

      do_sync_installation(installation, ids_to_delete, payloads)
    else
      {:error, api_error} -> {:error, {:api_error, api_error}}
    end
  end

  @spec do_sync_installation(GithubAppInstallation.t(), list, list) ::
    aggregated_result()
  defp do_sync_installation(
    %GithubAppInstallation{} = installation, ids_to_delete, payloads_to_sync)
    when is_list(ids_to_delete) and is_list(payloads_to_sync) do

    Multi.new
    |> Multi.run(:delete, fn _ -> ids_to_delete |> delete_all()  end)
    |> Multi.run(:sync, fn _ -> installation |> sync_all(payloads_to_sync) end)
    |> Multi.run(:mark_processed, fn _ -> installation |> mark_processed() end)
    |> Repo.transaction()
    |> marshall_result()
  end

  @spec sync_all(GithubAppInstallation.t(), list) :: aggregated_result()
  defp sync_all(%GithubAppInstallation{} = installation, payloads)
    when is_list(payloads) do

    payloads
    |> Enum.map(&find_or_create(installation, &1))
    |> ResultAggregator.aggregate()
  end

  @spec delete_all(list) :: {:ok, list(GithubRepo.t)}
  defp delete_all(github_ids) when is_list(github_ids) do
    GithubRepo
    |> where([r], r.github_id in ^github_ids)
    |> Repo.delete_all(returning: true)
    |> (fn {_count, records} -> {:ok, records} end).()
  end

  @spec find_or_create(GithubAppInstallation.t(), map) :: {:ok, GithubRepo.t()} | {:error, Changeset.t()}
  defp find_or_create(%GithubAppInstallation{} = installation, %{} = payload) do
    case find_repo(payload) do
      nil -> create_repo(installation, payload)
      %GithubRepo{} = repo -> repo |> update_repo(payload)
    end
  end

  @spec find_repo(map) :: GithubRepo.t() | nil
  defp find_repo(%{"id" => github_id}) do
    GithubRepo
    |> Repo.get_by(github_id: github_id)
    |> Repo.preload(:github_app_installation)
  end

  @spec create_repo(GithubAppInstallation.t(), map) :: commit_result()
  defp create_repo(%GithubAppInstallation{} = installation, %{} = payload) do

    attrs =
      payload
      |> Adapters.Repo.from_api()
      |> Map.merge(installation |> Adapters.AppInstallation.to_github_repo_attrs())

    %GithubRepo{}
    |> GithubRepo.changeset(attrs)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  @spec update_repo(GithubRepo.t(), map) :: commit_result()
  defp update_repo(%GithubRepo{} = github_repo, %{} = payload) do
    github_repo
    |> Changeset.change(payload |> Adapters.Repo.from_api())
    |> Repo.update()
  end

  @spec mark_processed(GithubAppInstallation.t()) :: {:ok, GithubAppInstallation.t()}
  defp mark_processed(%GithubAppInstallation{} = installation) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{sync: synced_repos, delete: deleted_repos}}) do
    {:ok, {synced_repos, deleted_repos}}
  end
  defp marshall_result({:error, errored_step, error_response, _steps}) do
    {:error, {errored_step, error_response}}
  end
end
