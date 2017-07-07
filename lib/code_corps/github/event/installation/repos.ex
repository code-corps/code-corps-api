defmodule CodeCorps.GitHub.Event.Installation.Repos do
  @moduledoc """
  In charge of processing repos during an installation event
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Installation,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter

  alias Ecto.{Changeset, Multi}

  @typep outcome :: {:ok, list(GithubRepo.t)} |
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
      |> Multi.run(:process_repos, &process_repos/1)
      |> Multi.run(:stop_processing, &stop_processing/1)

    case Repo.transaction(multi) do
      {:ok, %{processing_installation: _, process_repos: github_repos, stop_processing: processed_installation}} ->
        {:ok, processed_installation |> Map.put(:github_repos, github_repos)}
      {:error, :process_repos, error, _} -> {:error, error}
    end
  end

  @spec process_repos(%{processing_installation: GithubAppInstallation.t}) :: outcome
  defp process_repos(%{processing_installation: %GithubAppInstallation{} = installation}) do
    case installation |> Installation.repositories() do
      {:error, reason} -> {:error, reason}
      {:ok, response} ->
        adapter_results = response |> Enum.map(&GithubRepoAdapter.from_api/1)
        case adapter_results |>  Enum.all?(&valid?/1) do
          true -> installation |> create_all_repositories(adapter_results)
          false -> {:error, :invalid_repo_payload}
        end
    end
  end

  @spec valid?(any) :: boolean
  defp valid?({:error, _}), do: false
  defp valid?(_), do: true

  @spec create_all_repositories(GithubAppInstallation.t, list(map)) :: {:ok, list(GithubRepo.t)}
  defp create_all_repositories(%GithubAppInstallation{} = installation, attrs_list) when is_list(attrs_list) do
    github_repos =
      attrs_list
      |> Enum.map(fn attrs -> create_repository(installation, attrs) end)
      |> Enum.map(&Tuple.to_list/1) # {:ok, repo} -> [:ok, repo]
      |> Enum.map(&List.last/1) # [:ok, repo] -> repo

    {:ok, github_repos}
  end

  @spec create_repository(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp create_repository(%GithubAppInstallation{} = installation, repo_attributes) do
    %GithubRepo{}
    |> Changeset.change(repo_attributes)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  @spec stop_processing(%{processing_installation: GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp stop_processing(%{processing_installation: %GithubAppInstallation{} = installation}) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end
end
