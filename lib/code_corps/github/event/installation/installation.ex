defmodule CodeCorps.GitHub.Event.Installation do
  @moduledoc """
  In charge of handling a GitHub Webhook payload for the Installation event type
  [https://developer.github.com/v3/activity/events/types/#installationevent](https://developer.github.com/v3/activity/events/types/#installationevent)
  """

  @behaviour CodeCorps.GitHub.Event.Handler

  alias CodeCorps.{
    GithubAppInstallation,
    GitHub.Event.Installation,
    Repo,
    User
  }

  alias Ecto.{Changeset, Multi}

  @type outcome :: {:ok, GithubAppInstallation.t} |
                    {:error, :not_yet_implemented} |
                    {:error, :unexpected_action} |
                    {:error, :unexpected_payload} |
                    {:error, :validation_error_on_syncing_installation} |
                    {:error, :multiple_unprocessed_installations_found} |
                    {:error, :github_api_error_on_syncing_repos} |
                    {:error, :validation_error_on_deleting_removed_repos} |
                    {:error, :validation_error_on_syncing_existing_repos} |
                    {:error, :validation_error_on_marking_installation_processed}

  @doc """
  Handles the "Installation" GitHub Webhook event.

  The event could be of subtype `created` or `deleted`. Only the `created`
  variant is handled at the moment.

  The process of handling the "created" event subtype is as follows

  - try to match the sender with an existing `CodeCorps.User`
  - call specific matching module depending on the user being matched or not
    - `CodeCorps.GitHub.Event.Installation.MatchedUser.handle/2`
    - `CodeCorps.GitHub.Event.Installation.UnmatchedUser.handle/1`
  - sync installation repositories using a third modules
    - `CodeCorps.GitHub.Event.Installation.Repos.process/1`

  If everything goes as expected, an `:ok` tuple will be returned, with a
  `CodeCorps.GithubAppInstallation`, marked as "processed".

  If a step in the process failes, an `:error` tuple will be returned, where the
  second element is an atom indicating which step of the process failed.
  """
  @spec handle(map) :: outcome
  def handle(payload) do
    Multi.new
    |> Multi.run(:payload, fn _ -> payload |> validate_payload() end)
    |> Multi.run(:action, fn _ -> payload |> validate_action() end)
    |> Multi.run(:user, fn _ -> payload |> find_user() end)
    |> Multi.run(:installation, fn %{user: user} -> install_for_user(user, payload) end)
    |> Multi.merge(&process_repos/1)
    |> Repo.transaction
    |> marshall_result()
  end

  @spec find_user(map) :: {:ok, User.t} | {:ok, nil} | {:error, :unexpected_user_payload}
  defp find_user(%{"sender" => %{"id" => github_id}}) do
    user = Repo.get_by(User, github_id: github_id)
    {:ok, user}
  end
  defp find_user(_), do: {:error, :unexpected_user_payload}

  @spec install_for_user(User.t, map) :: outcome
  defp install_for_user(%User{} = user, payload) do
    Installation.MatchedUser.handle(user, payload)
  end
  defp install_for_user(nil, payload) do
    Installation.UnmatchedUser.handle(payload)
  end

  @spec process_repos(%{installation: GithubAppInstallation.t}) :: Multi.t
  defp process_repos(%{installation: %GithubAppInstallation{} = installation}) do
    installation
    |> Repo.preload(:github_repos)
    |> Installation.Repos.process
  end

  @spec marshall_result(tuple) :: tuple
  defp marshall_result({:ok, %{processed_installation: installation}}), do: {:ok, installation}
  defp marshall_result({:error, :payload, :invalid, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :action, :unexpected_action, _steps}), do: {:error, :unexpected_action}
  defp marshall_result({:error, :action, :not_yet_implemented, _steps}), do: {:error, :not_yet_implemented}
  defp marshall_result({:error, :user, :unexpected_user_payload, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :installation, :unexpected_installation_payload, _steps}), do: {:error, :unexpected_payload}
  defp marshall_result({:error, :installation, %Changeset{}, _steps}), do: {:error, :validation_error_on_syncing_installation}
  defp marshall_result({:error, :installation, :too_many_unprocessed_installations, _steps}), do: {:error, :multiple_unprocessed_installations_found}
  defp marshall_result({:error, :api_response, %CodeCorps.GitHub.APIError{}, _steps}), do: {:error, :github_api_error_on_syncing_repos}
  defp marshall_result({:error, :deleted_repos, {_results, _changesets}, _steps}), do: {:error, :validation_error_on_deleting_removed_repos}
  defp marshall_result({:error, :synced_repos, {_results, _changesets}, _steps}), do: {:error, :validation_error_on_syncing_existing_repos}
  defp marshall_result({:error, :processed_installation, %Changeset{}, _steps}), do: {:error, :validation_error_on_marking_installation_processed}
  defp marshall_result({:error, _errored_step, _error_response, _steps}), do: {:error, :unexpected_transaction_outcome}

  @spec validate_payload(map) :: {:ok, :valid} | {:error, :invalid}
  defp validate_payload(%{} = payload) do
    case payload |> Installation.Validator.valid? do
      true -> {:ok, :valid}
      false -> {:error, :invalid}
    end
  end

  @spec validate_action(map) :: {:ok, :implemented} |
                                {:error, :not_yet_implemented} |
                                {:error, :unexpected_action}
  defp validate_action(%{"action" => "created"}), do: {:ok, :implemented}
  defp validate_action(%{"action" => "deleted"}), do: {:error, :not_yet_implemented}
  defp validate_action(%{}), do: {:error, :unexpected_action}
end
