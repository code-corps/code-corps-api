defmodule CodeCorps.GitHub.Event.IssueComment do
  @moduledoc """
  In charge of dealing with "IssueComment" GitHub Webhook events
  """

  alias CodeCorps.GithubEvent

  @doc """
  Handles an "IssueComment" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  def handle(%GithubEvent{}, %{}), do: {:error, :not_fully_implemented}
end
