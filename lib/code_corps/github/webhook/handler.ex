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
    GitHub.Webhook.EventSupport,
    Repo
  }

  @doc """
  Handles a GitHub event based on its type.
  """
  def handle(type, id, payload) do
    with %{} = params <- build_params(type, id, payload),
         {:ok, %GithubEvent{} = event} <- params |> create_event(),
         {:ok, %GithubEvent{status: "processing"} = event} <- event |> Event.start_processing
    do
      payload |> do_handle(type) |> Event.stop_processing(event)
    end
  end

  defp build_params(type, id, %{"action" => action, "sender" => _} = payload) do
    %{
      action: action,
      github_delivery_id: id,
      payload: payload,
      status: type |> get_status(),
      type: type
    }
  end

  defp create_event(params) do
    %GithubEvent{} |> GithubEvent.changeset(params) |> Repo.insert
  end

  defp get_status(type) do
    case EventSupport.status(type) do
      :unsupported -> "unhandled"
      :supported -> "unprocessed"
    end
  end

  defp do_handle(payload, "installation"), do: Installation.handle(payload)
  defp do_handle(payload, "installation_repositories"), do: InstallationRepositories.handle(payload)
  defp do_handle(payload, "issue_comment"), do: IssueComment.handle(payload)
  defp do_handle(payload, "issues"), do: Issues.handle(payload)
end
