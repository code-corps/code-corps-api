defmodule CodeCorps.GitHub.Event.Installation do
  @moduledoc """
  In charge of dealing with "Installation" GitHub Webhook events
  """

  alias CodeCorps.{
    GitHub,
    GithubAppInstallation,
    GithubEvent,
    GithubRepo,
    GitHub.Event,
    Repo,
    User
  }

  alias CodeCorps.GitHub.Adapters.GithubRepo, as: GithubRepoAdapter
  alias Ecto.{Changeset, Multi}

  @doc """
  Handles an "Installation" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  @spec handle(GithubEvent.t, map) :: {:ok, GithubEvent.t}
  def handle(%GithubEvent{action: action} = event, payload) do
    event
    |> Event.start_processing()
    |> do_handle(action, payload)
    |> Event.stop_processing(event)
  end

  @typep outcome :: {:ok, GithubAppInstallation.t} | {:error, any}

  @spec do_handle({:ok, GithubEvent.t}, String.t, map) :: outcome
  defp do_handle({:ok, %GithubEvent{}}, "created", %{"installation" => installation_attrs, "sender" => sender_attrs}) do
    case {sender_attrs |> find_user, installation_attrs |> find_installation} do
      {nil, nil} -> create_unmatched_user_installation(installation_attrs)
      {%User{} = user, nil} -> create_installation_initiated_on_github(user, installation_attrs)
      {%User{}, %GithubAppInstallation{} = installation} -> update_matched_installation(installation)
      {nil, %GithubAppInstallation{}} -> {:error, :unhandled_installation_case}
    end
  end

  @spec create_unmatched_user_installation(map) :: {:ok, GithubAppInstallation.t}
  defp create_unmatched_user_installation(%{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "unmatched_user"})
    |> Repo.insert()
  end

  @spec create_installation_initiated_on_github(User.t, map) :: {:ok, GithubAppInstallation.t}
  defp create_installation_initiated_on_github(%User{} = user, %{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "initiated_on_github"})
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @spec update_matched_installation(GithubAppInstallation.t) :: outcome
  defp update_matched_installation(%GithubAppInstallation{} = installation) do
    processing_changeset =
      installation
      |> Changeset.change(%{installed: true, state: "processing"})

    multi =
      Multi.new
      |> Multi.update(:processing_installation, processing_changeset)
      |> Multi.run(:process_repos, &process_repos/1)
      |> Multi.run(:stop_processing, &stop_processing/1)

    case Repo.transaction(multi) do
      {:ok, %{processing_installation: _, process_repos: github_repos, stop_processing: processed_installation}} ->
        {:ok, processed_installation |> Map.put(:github_repos, github_repos)}
      {:error, :api_error} -> {:error, :api_error}
      {:error, :invalid_repo_payload} -> {:error, :invalid_repo_payload}
    end
  end

  @spec find_installation(map) :: GithubAppInstallation.t | nil
  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)

  @spec find_user(map) :: User.t | nil
  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)

  @typep repo_processing_outcome :: {:ok, list(GithubRepo.t)} | {:error, any}

  @spec process_repos(%{processing_installation: GithubAppInstallation.t}) :: repo_processing_outcome
  defp process_repos(%{processing_installation: %GithubAppInstallation{} = installation}) do
    case installation |> GitHub.Installation.repositories() do
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
