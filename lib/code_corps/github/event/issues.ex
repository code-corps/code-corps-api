defmodule CodeCorps.GitHub.Event.Issues do
  @moduledoc """
  In charge of dealing with "Issues" GitHub Webhook events
  """

  alias CodeCorps.GithubEvent

  @doc """
  Handles an "Issues" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  def handle(%GithubEvent{}, %{}), do: :not_fully_implemented
end
