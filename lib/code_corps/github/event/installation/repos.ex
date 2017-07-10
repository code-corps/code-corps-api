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

  @typep result_atom :: :ok | :error
  @typep repo_result :: {result_atom, GithubRepo.t | Changeset.t}
  @typep aggregated_result :: {result_atom, list(GithubRepo.t | Changeset.t)}

  @typep outcome :: aggregated_result |
                    {:error, CodeCorps.GitHub.api_error_struct} |
                    {:error, :invalid_repo_payload}

  @doc ~S"""
  Fetches a list of repositories for a `GithubAppInstallation` from the GitHub
  API, then creates a `GithubRepo` record for each of those repositories.
  """
  @spec process(GithubAppInstallation.t) :: outcome
  def process(%GithubAppInstallation{} = installation) do
    multi =
      Multi.new
      |> Multi.update(:processing_installation, installation |> Changeset.change(%{state: "processing"}))
      |> Multi.run(:api_response, &fetch_api_repo_list/1)
      |> Multi.run(:repo_attrs_list, &adapt_api_repo_list/1)
      |> Multi.run(:deleted_repos, &delete_repos/1)
      |> Multi.run(:synced_repos, &sync_repos/1)
      |> Multi.run(:processed_installation, &stop_processing/1)

    case Repo.transaction(multi) do
      {:ok, %{
        processing_installation: _processing_installation,
        api_response: _api_repo_list,
        repo_attrs_list: _repo_attrs_list,
        deleted_repos: _deleted_repos,
        synced_repos: synced_repos,
        processed_installation: processed_installation}} ->

        {:ok, processed_installation |> Map.put(:github_repos, synced_repos)}
      {:error, _step, error, _} ->
        {:error, error}
    end
  end

  @spec fetch_api_repo_list(%{processing_installation: GithubAppInstallation.t}) :: {:ok, map} | {:error, GitHub.api_error_struct}
  defp fetch_api_repo_list(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation |> Installation.repositories()
  end

  @spec adapt_api_repo_list(%{api_response: any}) :: list(map) | {:error, :invalid_repo_payload}
  defp adapt_api_repo_list(%{api_response: repositories}) do
    adapter_results = repositories |> Enum.map(&GithubRepoAdapter.from_api/1)
    case adapter_results |>  Enum.all?(&valid?/1) do
      true -> {:ok, adapter_results}
      false -> {:error, :invalid_repo_payload}
    end
  end

  @spec valid?(any) :: boolean
  defp valid?({:error, _}), do: false
  defp valid?(_), do: true

  @spec delete_repos(%{processing_installation: GithubAppInstallation.t, repo_attrs_list: list(map)}) :: aggregated_result
  defp delete_repos(%{
    processing_installation: %GithubAppInstallation{github_repos: github_repos},
    repo_attrs_list: attrs_list
  }) when is_list(attrs_list) do
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

  @spec sync_repos(%{processing_installation: GithubAppInstallation.t, repo_attrs_list: list(map)}) :: aggregated_result
  defp sync_repos(%{
    processing_installation: %GithubAppInstallation{} = installation,
    repo_attrs_list: attrs_list
  }) when is_list(attrs_list) do

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

  @spec reduce(list(repo_result), result_atom) :: aggregated_result
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
    |> Changeset.change(repo_attributes)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  @spec update(GithubRepo.t, map) :: {:ok, GithubRepo.t}
  defp update(%GithubRepo{} = github_repo, %{} = repo_attributes) do
    github_repo
    |> Changeset.change(repo_attributes)
    |> Repo.update()
  end

  @spec stop_processing(%{processing_installation: GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp stop_processing(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end
end
