defmodule CodeCorps.GitHub.Event.Installation.Repos do
  @moduledoc """
  In charge of processing repos during an installation event
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Installation,
    GitHub,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  alias Ecto.{Changeset, Multi}

  @typep repo_result :: {:ok | :error, GithubRepo.t | Changeset.t}
  @typep aggregated_result :: {:ok | :error, list(GithubRepo.t | Changeset.t)}

  @doc ~S"""
  Marks a `GithubAppInstallation` as "processing" and immediately returns it.

  In the background, it fires a task to asynchronously call &process/1
  """
  @spec process_async(GithubAppInstallation.t) :: {:ok, GithubAppInstallation.t, Task.t}
  def process_async(%GithubAppInstallation{} = installation) do
    {:ok, %GithubAppInstallation{} = processing_installation} = installation |> set_state("processing")

    task = Task.Supervisor.async(:background_processor, fn -> processing_installation |> process() end)

    {:ok, processing_installation, task}
  end

  @doc ~S"""
  Fetches a list of repositories for a `GithubAppInstallation` from the GitHub
  API and matches up `GithubRepo` records stored locally using that list as the
  master list.
  """
  @spec process(GithubAppInstallation.t) :: {:ok | :error, GithubAppInstallation.t}
  def process(%GithubAppInstallation{} = installation) do
    multi =
      Multi.new
      |> Multi.run(:processing_installation, fn _ -> {:ok, installation} end)
      |> Multi.run(:api_response, &fetch_api_repo_list/1)
      |> Multi.run(:repo_attrs_list, &adapt_api_repo_list/1)
      |> Multi.run(:deleted_repos, &delete_repos/1)
      |> Multi.run(:synced_repos, &sync_repos/1)
      |> Multi.run(:processed_installation, &mark_processed/1)

    case Repo.transaction(multi) do
      {:ok, %{processed_installation: installation}} ->
        {:ok, installation}
      {:error, _errored_step, error_response, _steps} ->
        {:ok, errored_installation} = installation |> set_state("errored")
        {:error, errored_installation, error_response}
    end
  end

  @spec set_state(GithubAppInstallation.t, String.t) :: {:ok, GithubAppInstallation.t}
  defp set_state(%GithubAppInstallation{} = installation, state) when state in ~w(processing processed errored) do
    installation
    |> Changeset.change(%{state: state})
    |> Repo.update
  end

  # transaction step 1
  @spec fetch_api_repo_list(%{processing_installation: GithubAppInstallation.t}) :: {:ok, map} | {:error, GitHub.api_error_struct}
  defp fetch_api_repo_list(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation |> Installation.repositories()
  end

  # transaction step 2
  @spec adapt_api_repo_list(%{api_response: any}) :: {:ok, list(map)}
  defp adapt_api_repo_list(%{api_response: repositories}) do
    adapter_results = repositories |> Enum.map(&GithubRepoAdapter.from_api/1)
    {:ok, adapter_results}
  end

  # transaction step 3
  @spec delete_repos(%{processing_installation: GithubAppInstallation.t, repo_attrs_list: list(map)}) :: aggregated_result
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
    |> aggregate
  end

  # transaction step 4
  @spec sync_repos(%{processing_installation: GithubAppInstallation.t, repo_attrs_list: list(map)}) :: aggregated_result
  defp sync_repos(%{
    processing_installation: %GithubAppInstallation{} = installation,
    repo_attrs_list: attrs_list }) when is_list(attrs_list) do

    attrs_list
    |> Enum.map(&sync(installation, &1))
    |> aggregate
  end

  @spec aggregate(list(repo_result)) :: aggregated_result
  defp aggregate(results) do
    case results |> Enum.filter(fn {state, _data} -> state == :error end) do
      [] -> results |> reduce(:ok)
      errors -> errors |> reduce(:error)
    end
  end

  @spec reduce(list(repo_result), :ok | :error) :: aggregated_result
  defp reduce(data, state) when state in [:ok, :error] do
    data
    |> Enum.map(&Tuple.to_list/1) # {:ok, repo} -> [:ok, repo]
    |> Enum.map(&Enum.at(&1, 1)) # [:ok, repo] -> repo
    |> (fn data -> {state, data} end).() # repos -> {:ok, repos}
  end

  @spec sync(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp sync(%GithubAppInstallation{github_repos: github_repos} = installation, %{github_id: github_id} = repo_attributes) do
    case github_repos |> Enum.find(fn %GithubRepo{} = gr -> gr.github_id == github_id end) do
      nil -> create(installation, repo_attributes)
      %GithubRepo{} = github_repo -> github_repo |> update(repo_attributes)
    end
  end

  @spec create(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp create(%GithubAppInstallation{} = installation, %{} = repo_attributes) do
    %GithubRepo{}
    |> changeset(repo_attributes)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  @spec update(GithubRepo.t, map) :: {:ok, GithubRepo.t}
  defp update(%GithubRepo{} = github_repo, %{} = repo_attributes) do
    github_repo
    |> changeset(repo_attributes)
    |> Repo.update()
  end

  @spec changeset(GithubRepo.t, map) :: Changeset.t
  defp changeset(%GithubRepo{} = github_repo, %{} = repo_attributes) do
    github_repo
    |> Changeset.change(repo_attributes)
    |> Changeset.validate_required([
      :github_id, :name, :github_account_id,
      :github_account_avatar_url, :github_account_login, :github_account_type
    ])
  end

  # transaction step 5
  @spec mark_processed(%{processing_installation: GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp mark_processed(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation |> set_state("processed")
  end
end
