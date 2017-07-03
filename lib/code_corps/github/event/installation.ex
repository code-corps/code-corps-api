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

  alias Ecto.Changeset

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

  @spec do_handle({:ok, GithubEvent.t}, String.t, map) :: {:ok, GithubAppInstallation.t} | {:error, :api_error}
  defp do_handle({:ok, %GithubEvent{}}, "created", %{"installation" => installation_attrs, "sender" => sender_attrs}) do
    case {sender_attrs |> find_user, installation_attrs |> find_installation} do
      {nil, nil} -> create_unmatched_user_installation(installation_attrs)
      {%User{} = user, nil} -> create_installation_initiated_on_github(user, installation_attrs)
      {%User{}, %GithubAppInstallation{} = installation} -> create_matched_installation(installation)
    end
  end

  @spec create_installation_initiated_on_github(User.t, map) :: {:ok, GithubAppInstallation.t}
  defp create_installation_initiated_on_github(%User{} = user, %{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "initiated_on_github"})
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @spec create_matched_installation(GithubAppInstallation.t) :: {:ok, GithubAppInstallation.t}
  defp create_matched_installation(%GithubAppInstallation{} = installation) do
    installation
    |> start_installation_processing()
    |> process_repos()
    |> stop_installation_processing()
  end

  @spec create_unmatched_user_installation(map) :: {:ok, GithubAppInstallation.t}
  defp create_unmatched_user_installation(%{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "unmatched_user"})
    |> Repo.insert()
  end

  @spec create_repository(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t}
  defp create_repository(%GithubAppInstallation{} = installation, repo_attributes) do
    %GithubRepo{}
    |> Changeset.change(repo_attributes |> GithubRepoAdapter.from_api)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  @spec find_installation(map) :: GithubAppInstallation.t | nil
  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)

  @spec find_user(map) :: User.t | nil
  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)

  @spec process_repos({:ok, GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t} | {:error, :api_error}
  defp process_repos({:ok, %GithubAppInstallation{} = installation}) do
    with {:ok, repo_payloads} <- installation |> GitHub.Installation.repositories() do
      repositories =
        repo_payloads
        |> Enum.map(&create_repository(installation, &1))
        |> Enum.map(fn {:ok, repository} -> repository end)

        {:ok, installation |> Map.put(:github_repos, repositories)}
    end
  end

  @spec start_installation_processing({:ok, GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp start_installation_processing(%GithubAppInstallation{} = installation) do
    installation
    |> Changeset.change(%{installed: true, state: "processing"})
    |> Repo.update()
  end

  @spec stop_installation_processing({:ok, GithubAppInstallation.t}) :: {:ok, GithubAppInstallation.t}
  defp stop_installation_processing({:ok, %GithubAppInstallation{} = installation}) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end
end
