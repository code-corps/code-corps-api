defmodule CodeCorps.GitHub.Event.Installation do
  @moduledoc """
  In charge of dealing with "Installation" GitHub Webhook events
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GitHub.Event.Installation.UnmatchedUser,
    GitHub.Event.Installation.MatchedUser,
    GitHub.Event.Installation.Repos,
    Repo,
    User
  }

  @typep outcome :: {:ok, GithubAppInstallation.t, Task.t} | {:error, any}

  @doc """
  Handles an "Installation" GitHub Webhook event. The event could be
  of subtype "created" or "deleted". Only the "created" variant is handled at
  the moment.

  `Installation::created` will first try to find the `User` using information
  from the payload.

  Depending on the outcame of that operation, it will either call one of

  - `CodeCorps.GitHub.Event.Installation.UnmatchedUser.handle/2`
  - `CodeCorps.GitHub.Event.Installation.MatchedUser.handle/2`

  These helper modules will create or update the `GithubAppInstallation` with
  proper data.

  Once that is done, the outcome will be returned.

  Additionally, a background task will launch
  `CodeCorps.GitHub.Event.Installation.Repos.process_async` to asynchronously
  fetch and process repositories for the installation.

  The installation will initially be returned with the state "processing", but
  in the background, it will eventually switch to either "processed" or
  "errored".
  """
  @spec handle(GithubEvent.t, map) :: outcome
  def handle(%GithubEvent{action: action}, payload),
    do: action |> do_handle(payload) |> postprocess()

  @spec do_handle(String.t, map) :: outcome
  defp do_handle(
      "created",
      %{"installation" => %{"id" => _} = installation_attrs,
      "sender" => %{"id" => _} = sender_attrs}
    ) do

    case sender_attrs |> find_user() do
      # No user was found with the specified github_id
      nil -> UnmatchedUser.handle(installation_attrs, sender_attrs)
      # A user was found, matching the sspecified github_id
      %User{} = user -> MatchedUser.handle(user, installation_attrs)
    end
  end
  defp do_handle(_action, _payload), do: {:error, :unexpected_action_or_payload}

  @spec postprocess({:ok, GithubAppInstallation.t} | {:error, any}) :: {:ok, GithubAppInstallation.t} | {:error, any}
  defp postprocess({:ok, %GithubAppInstallation{} = installation}) do
    installation
    |> Repo.preload(:github_repos)
    |> Repos.process_async
  end
  defp postprocess({:error, error}), do: {:error, error}

  @spec find_user(any) :: User.t | nil
  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)
  defp find_user(_), do: :unexpected_user_payload
end
