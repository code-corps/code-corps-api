defmodule CodeCorps.GitHub.Webhook.Handler do
  @moduledoc """
  Receives and handles GitHub event payloads.
  """

  alias CodeCorps.{
    GithubEvent,
    GitHub.Event,
    GitHub.Event.Installation,
    GitHub.Event.InstallationRepositories,
    GitHub.Event.IssueComment,
    GitHub.Event.Issues,
    GitHub.Event.PullRequest,
    Repo
  }

  @doc """
  Handles a fully supported GitHub event based on its type and action.

  The handling process consistes of 3 steps

  - create event record marked as "unprocessed"
  - mark event record as processing and handle it
  - mark event record as processed or errored depending on handling outcome
  """
  @spec handle_supported(String.t, String.t, map) :: {:ok, GithubEvent.t}
  def handle_supported(type, id, %{} = payload) do
    with {:ok, %GithubEvent{} = event} <- find_or_create_event(type, id, payload, "unprocessed") do
      payload |> apply_handler(type) |> Event.stop_processing(event)
    end
  end

  @doc ~S"""
  Handles an unsupported supported GitHub event.

  "unsupported" means that, while we generally support this event type,
  we do not yet support this specific event action.

  The process consistes of simply storing the event and marking it as
  "unsupported".
  """
  @spec handle_unsupported(String.t, String.t, map) :: {:ok, GithubEvent.t}
  def handle_unsupported(type, id, %{} = payload) do
    find_or_create_event(type, id, payload, "unsupported")
  end

  @spec build_params(String.t, String.t, String.t, map) :: map
  defp build_params(type, id, status, %{"action" => action} = payload) do
    %{
      action: action,
      github_delivery_id: id,
      payload: payload,
      status: status,
      type: type
    }
  end

  @spec find_or_create_event(String.t, String.t, map, String.t) :: {:ok, GithubEvent.t}
  defp find_or_create_event(type, id, payload, status) do
    case GithubEvent |> Repo.get_by(github_delivery_id: id) do
      nil -> type |> build_params(id, status, payload) |> create_event()
      %GithubEvent{} = github_event -> {:ok, github_event}
    end
  end

  @spec create_event(map) :: {:ok, GithubEvent.t}
  defp create_event(%{} = params) do
    %GithubEvent{} |> GithubEvent.changeset(params) |> Repo.insert()
  end

  @spec apply_handler(map, String.t) :: tuple
  defp apply_handler(payload, "installation"), do: Installation.handle(payload)
  defp apply_handler(payload, "installation_repositories"), do: InstallationRepositories.handle(payload)
  defp apply_handler(payload, "issue_comment"), do: IssueComment.handle(payload)
  defp apply_handler(payload, "issues"), do: Issues.handle(payload)
  defp apply_handler(payload, "pull_request"), do: PullRequest.handle(payload)
end
