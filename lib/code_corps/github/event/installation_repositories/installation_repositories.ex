defmodule CodeCorps.GitHub.Event.InstallationRepositories do
  @moduledoc ~S"""
  In charge of handling a GitHub Webhook payload for the
  InstallationRepositories event type.

  [https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent](https://developer.github.com/v3/activity/events/types/#installationrepositoriesevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GitHub.Sync,
    GithubRepo,
    GitHub.Event.InstallationRepositories
  }

  @type outcome :: {:ok, list(GithubRepo.t())} |
                   {:error, :unmatched_installation} |
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
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    with {:ok, :valid} <- payload |> validate_payload() do
      Sync.installation_repositories_event(payload)
    else
      {:error, :invalid} -> {:error, :unexpected_payload}
    end
  end

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> InstallationRepositories.Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end
end
