defmodule CodeCorps.GitHub.Webhook.Handler do
  @moduledoc """
  Receives and handles GitHub event payloads.
  """

  alias CodeCorps.{
    GithubEvent,
    GitHub.Event.Installation,
    GitHub.Event.InstallationRepositories,
    GitHub.Event.IssueComment,
    GitHub.Event.Issues,
    GitHub.Webhook.EventSupport,
    Repo
  }

  @doc """
  Handles a GitHub event based on its type.
  """
  def handle(type, id, payload) do
    with %{} = params <- build_params(type, id, payload),
         {:ok, %GithubEvent{} = event} <- params |> create_event()
    do
      event |> process_payload(payload)
    end
  end

  defp build_params(type, id, %{"action" => action, "sender" => sender}) do
    %{
      action: action,
      github_delivery_id: id,
      source: sender |> get_source(),
      status: type |> get_status(),
      type: type
    }
  end

  defp create_event(params) do
    %GithubEvent{} |> GithubEvent.changeset(params) |> Repo.insert
  end

  defp get_source(_), do: "not implemented"

  defp get_status(type) do
    case EventSupport.status(type) do
      :unsupported -> "unhandled"
      :supported -> "unprocessed"
    end
  end

  defp process_payload(%GithubEvent{type: "installation"} = event, payload),
    do: Installation.handle(event, payload)
  defp process_payload(%GithubEvent{type: "installation_repositories"} = event, payload),
    do: InstallationRepositories.handle(event, payload)
  defp process_payload(%GithubEvent{type: "issue_comment"} = event, payload),
    do: IssueComment.handle(event, payload)
  defp process_payload(%GithubEvent{type: "issues"} = event, payload),
    do: Issues.handle(event, payload)
end
