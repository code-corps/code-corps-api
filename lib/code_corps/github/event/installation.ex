defmodule CodeCorps.GitHub.Event.Installation do
  @moduledoc """
  In charge of dealing with "Installation" GitHub Webhook events
  """

  alias CodeCorps.{
    GithubAppInstallation,
    GithubEvent,
    GitHub.Event,
    GitHub.Event.Installation.UnmatchedUser,
    GitHub.Event.Installation.MatchedUser,
    Repo,
    User
  }

  @doc """
  Handles an "Installation" GitHub Webhook event. The event could be
  of subtype "created" or "deleted". Only the "created" variant is handled at
  the moment.

  `InstallationCrreated::added` will first try to find the `User` and the
  `GithubAppInstallation`, using information from the payload.
    - if neither are found, it will
      - create a fresh `GithubAppInstallation`, with status "unmatched_user"
    - if only the `User` is found, it will
      - create `GithubAppInstallation` with status "initiated_on_github",
        associated with the `User`
    - if both are found, it will
      - fetch repositories for the installation, create `GithubRepo` records
      - mark installation as processed
    - find `GithubAppInstallation`
      - marks event as errored if not found
      - marks event as errored if payload does not have keys it needs, meaning
        there's something wrong with our code and we need to updated
    - find or create `GithubRepo` records affected

    At the end of the process, the associated event will me marked as
    "processed". If any failure occurs, the event will be marked as "errored".

    Potential points of failure:
    - the installation is found, but the user is not
    - problem communicating with the API
    - the payload received is not of the expected structure
    - the action type is not one of the supported types ("created")
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
  defp do_handle({:ok, %GithubEvent{}}, "created", %{"installation" => %{"id" => _} = installation_attrs, "sender" => %{"id" => _} = sender_attrs}) do
    case sender_attrs |> find_user() do
      # No user was found with the specified github_id
      nil -> UnmatchedUser.handle(installation_attrs, sender_attrs)
      # A user was found, matching the sspecified github_id
      %User{} = user -> MatchedUser.handle(user, installation_attrs)
    end
  end
  defp do_handle({:ok, %GithubEvent{}}, _action, _payload), do: {:error, :unexpected_action_or_payload}

  @spec find_user(any) :: User.t | nil
  defp find_user(%{"id" => github_id}), do: User |> Repo.get_by(github_id: github_id)
  defp find_user(_), do: :unexpected_user_payload
end
