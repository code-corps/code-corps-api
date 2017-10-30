defmodule CodeCorps.GitHub.Event.Installation.Repos do
  @moduledoc """
  In charge of processing repos during an installation event
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.API.Installation,
    GitHub,
    GitHub.Utils.ResultAggregator,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.Repo, as: RepoAdapter

  alias Ecto.{Changeset, Multi}

  @typep aggregated_result :: {:ok, list(GithubRepo.t)} |
                              {:error, {list(GithubRepo.t), list(Changeset.t)}}

  @doc ~S"""
  Creates and returns a multi used to sync a `CodeCorps.GithubRepo` records
  associated with the provided `CodeCorps.GithubAppInstallation` record, based
  on freshly retrieved GitHub data.

  Note that a GitHub API call is being called as part of this process.

  The list of repositories from the API call is considered the master list.
  - Anything existing locally, but not on this list is deleted.
  - Anything existing both locally and on this list is updated.
  - Anything existing not locally, but on this list is created.
  """
  @spec process(GithubAppInstallation.t) :: Multi.t
  def process(%GithubAppInstallation{} = installation) do
    Multi.new
    |> Multi.run(:processing_installation, fn _ -> {:ok, installation} end)
    |> Multi.run(:api_response, &fetch_api_repo_list/1)
    |> Multi.run(:repo_attrs_list, &adapt_api_repo_list/1)
    |> Multi.run(:deleted_repos, &delete_repos/1)
    |> Multi.run(:synced_repos, &sync_repos/1)
    |> Multi.run(:processed_installation, &mark_processed/1)
  end

  # transaction step 1
  @spec fetch_api_repo_list(map) :: {:ok, map} | {:error, GitHub.api_error_struct}
  defp fetch_api_repo_list(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation |> Installation.repositories()
  end

  # transaction step 2
  @spec adapt_api_repo_list(map) :: {:ok, list(map)}
  defp adapt_api_repo_list(%{api_response: repositories}) do
    adapter_results = repositories |> Enum.map(&RepoAdapter.from_api/1)
    {:ok, adapter_results}
  end

  # transaction step 3
  @spec delete_repos(map) :: aggregated_result
  defp delete_repos(%{
    processing_installation: %GithubAppInstallation{github_repos: github_repos},
    repo_attrs_list: attrs_list}) when is_list(attrs_list) do

    master_list = attrs_list |> Enum.map(&Map.get(&1, :github_id))

    github_repos
    |> Enum.map(fn %GithubRepo{} = github_repo ->
      case github_repo.github_id in master_list do
        false -> github_repo |> Repo.delete
        true -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> ResultAggregator.aggregate
  end

  # transaction step 4
  @spec sync_repos(map) :: aggregated_result
  defp sync_repos(%{
    processing_installation: %GithubAppInstallation{} = installation,
    repo_attrs_list: attrs_list }) when is_list(attrs_list) do

    attrs_list
    |> Enum.map(&sync(installation, &1))
    |> ResultAggregator.aggregate
  end

  @spec sync(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp sync(
    %GithubAppInstallation{github_repos: github_repos} = installation,
    %{github_id: github_id} = repo_attributes) do

    case github_repos |> Enum.find(fn %GithubRepo{} = gr -> gr.github_id == github_id end) do
      nil -> create(installation, repo_attributes)
      %GithubRepo{} = github_repo -> github_repo |> update(repo_attributes)
    end
  end

  @spec create(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp create(%GithubAppInstallation{id: installation_id}, %{} = repo_attributes) do
    params =
      repo_attributes
      |> Map.put(:github_app_installation_id, installation_id)

    %GithubRepo{}
    |> GithubRepo.changeset(params)
    |> Repo.insert()
  end

  @spec update(GithubRepo.t, map) :: {:ok, GithubRepo.t}
  defp update(%GithubRepo{} = github_repo, %{} = repo_attributes) do
    github_repo
    |> GithubRepo.changeset(repo_attributes)
    |> Repo.update()
  end

  # transaction step 5
  @spec mark_processed(%{processing_installation: GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp mark_processed(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update
  end
end
