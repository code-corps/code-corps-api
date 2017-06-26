defmodule CodeCorps.GitHub.Events.InstallationRepositories do
  @moduledoc """
  In charge of dealing with "InstallationRepositories" GitHub Webhook events
  """

  alias CodeCorps.GithubEvent

  @doc """
  Handles an "InstallationRepositories" GitHub Webhook event

  The general idea is
  - marked the passed in event as "processing"
  - do the work
  - marked the passed in event as "processed" or "errored"
  """
  def handle(%GithubEvent{}, %{}), do: :not_fully_implemented
end
