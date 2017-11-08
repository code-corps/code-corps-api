defmodule CodeCorps.GitHub.Event.InstallationRepositories do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the
  InstallationRepositories event type.

  [https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent](https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GithubAppInstallation,
    GithubRepo,
    GitHub.Utils.ResultAggregator,
    GitHub.Event.InstallationRepositories,
    Repo
  }

  alias CodeCorps.GitHub.Adapters.AppInstallation, as: AppInstallationAdapter
  alias Ecto.{Changeset, Multi}

  @type outcome :: {:ok, list(GithubRepo.t)} |
                    {:error, :unmatched_installation} |
                    {:error, :unexpected_action} |
                    {:error, :unexpected_payload} |
                    {:error, :validation_error_on_syncing_repos} |
                    {:error, :unexpected_transaction_outcome}

  @doc """
  Handles an "InstallationRepositories" GitHub Webhook event. The event could be
  of subtype "added" or "removed" and is handled differently based on that.

  - the process of handling the "added" subtype is as follows
    - try to match with `CodeCorps.GithubAppInstallation` record
    - sync affected `CodeCorps.GithubRepo` records (update, create)

  - the process of handling the "removed" subtype is as follows
    - try to match with a `CodeCorps.GithubAppInstallation` record
    - delete affected `CodeCorps.GithubRepo` records, respecting the rules
      - if the GitHub payload for a repo is not matched with a record in our
        database, just skip deleting it
      - if the deleted `CodeCorps.GithubRepo` record is associated with
        `CodeCorps.ProjectGithubRepo` records, they are deleted automatically,
        due to `on_delete: :delete_all` set at the database level.
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    Multi.new
    |> Multi.run(:payload, fn _ -> payload |> validate_payload() end)
    |> Multi.run(:action, fn _ -> payload |> validate_action() end)
    |> Multi.run(:installation, fn _ -> payload |> match_installation() end)
    |> Multi.run(:repos, fn %{installation: installation} -> installation |> sync_repos(payload) end)
    |> Repo.transaction
    |> marshall_result()
  end

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> InstallationRepositories.Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end

  @valid_actions ~w(added removed)
  @spec validate_action(map) :: {:ok, :implemented} | {:error, :unexpected_action}
  defp validate_action(%{"action" => action}) when action in @valid_actions, do: {:ok, :implemented}
  defp validate_action(%{}), do: {:error, :unexpected_action}

  @spec match_installation(map) :: {:ok, GithubAppInstallation.t} |
                                   {:error, :unmatched_installation}
  defp match_installation(%{"installation" => %{"id" => github_id}}) do
    case GithubAppInstallation |> Repo.get_by(github_id: github_id) do
      nil -> {:error, :unmatched_installation}
      %GithubAppInstallation{} = installation -> {:ok, installation}
    end
  end
  defp match_installation(%{}), do: {:error, :unmatched_installation}

  @spec sync_repos(GithubAppInstallation.t, map) :: {:ok, list(GithubRepo.t)} | {:error, {list(GithubRepo.t), list(Changeset.t)}}
  defp sync_repos(%GithubAppInstallation{} = installation, %{"action" => "added", "repositories_added" => repositories}) do
    repositories
    |> Enum.map(&find_or_create(installation, &1))
    |> ResultAggregator.aggregate
  end
  defp sync_repos(%GithubAppInstallation{} = installation, %{"action" => "removed", "repositories_removed" => repositories}) do
    repositories
    |> Enum.map(&find_repo(installation, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Repo.delete/1)
    |> ResultAggregator.aggregate
  end

  @spec find_or_create(GithubAppInstallation.t, map) :: {:ok, GithubRepo.t} | {:error, Changeset.t}
  defp find_or_create(%GithubAppInstallation{} = installation, %{"id" => id, "name" => name} = attrs) do
    case find_repo(installation, attrs) do
      nil ->
        installation_repo_attributes =
          installation
          |> AppInstallationAdapter.to_github_repo_attrs()

        params =
          %{github_id: id, name: name}
          |> Map.merge(installation_repo_attributes)

        %GithubRepo{}
        |> Changeset.change(params)
        |> Changeset.put_assoc(:github_app_installation, installation)
        |> Repo.insert()
      %GithubRepo{} = github_repo ->
        github_repo
        |> Changeset.change(%{name: name})
        |> Repo.update()
    end
  end

  @spec find_repo(GithubAppInstallation.t, map) :: GithubRepo.t | nil
  defp find_repo(%GithubAppInstallation{id: installation_id}, %{"id" => github_id}) do
    GithubRepo
    |> Repo.get_by(github_app_installation_id: installation_id, github_id: github_id)
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{repos: repos}}), do: {:ok, repos}
  defp marshall_result({:error, :payload, :invalid, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :action, :unexpected_action, _steps}), do: {:error, :unexpected_action}
  defp marshall_result({:error, :installation, :unmatched_installation, _steps}), do: {:error, :unmatched_installation}
  defp marshall_result({:error, :repos, {_repos, _changesets}, _steps}), do: {:error, :validation_error_on_syncing_repos}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}
end
