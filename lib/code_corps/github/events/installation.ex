defmodule CodeCorps.GitHub.Events.Installation do
  @moduledoc """
  In charge of dealing with "Installation" GitHub Webhook events
  """

  alias CodeCorps.{
    GitHub,
    GithubAppInstallation,
    GithubEvent,
    GithubRepo,
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
  def handle(%GithubEvent{action: "created"} = event, payload) do
    event
    |> start_event_processing()
    |> do_handle(payload)
    |> stop_event_processing(event)
  end

  defp do_handle({:ok, %GithubEvent{}}, %{"installation" => installation_attrs, "sender" => sender_attrs}) do
    case {sender_attrs |> find_user, installation_attrs |> find_installation} do
      {nil, nil} -> create_unmatched_user_installation(installation_attrs)
      {%User{} = user, nil} -> create_installation_initiated_on_github(user, installation_attrs)
      {%User{}, %GithubAppInstallation{} = installation} -> create_matched_installation(installation)
    end
  end

  defp create_installation_initiated_on_github(%User{} = user, %{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "initiated_on_github"})
    |> Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  defp create_matched_installation(%GithubAppInstallation{} = installation) do
    installation
    |> start_installation_processing()
    |> process_repos()
    |> stop_installation_processing()
  end

  defp create_repository(%GithubAppInstallation{} = installation, repo_attributes) do
    %GithubRepo{}
    |> Changeset.change(repo_attributes |> GithubRepoAdapter.from_api)
    |> Changeset.put_assoc(:github_app_installation, installation)
    |> Repo.insert()
  end

  defp create_unmatched_user_installation(%{"id" => github_id}) do
    %GithubAppInstallation{}
    |> Changeset.change(%{github_id: github_id, installed: true, state: "unmatched_user"})
    |> Repo.insert()
  end

  defp find_installation(%{"id" => github_id}), do: GithubAppInstallation |> Repo.get_by(github_id: github_id)

  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)

  defp process_repos({:ok, %GithubAppInstallation{} = installation}) do
    # TODO: Consider moving into transaction
    {:ok, repositories} =
      installation
      |> GitHub.Installation.repositories()
      |> (fn {:ok, repositories} -> repositories end).()
      |> Enum.map(&create_repository(installation, &1))
      |> Enum.map(fn {:ok, repository} -> repository end)
      |> (fn repositories -> {:ok, repositories} end).()

    {:ok, installation |> Map.put(:github_repos, repositories)}
  end

  defp start_event_processing(%GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processing"}) |> Repo.update()
  end

  defp stop_event_processing({:ok, %GithubAppInstallation{}}, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processed"}) |> Repo.update
  end
  defp stop_event_processing(_, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "errored"}) |> Repo.update
  end

  defp start_installation_processing(%GithubAppInstallation{} = installation) do
    installation
    |> Changeset.change(%{installed: true, state: "processing"})
    |> Repo.update()
  end

  defp stop_installation_processing({:ok, %GithubAppInstallation{} = installation}) do
    installation
    |> Changeset.change(%{state: "processed"})
    |> Repo.update()
  end
end
