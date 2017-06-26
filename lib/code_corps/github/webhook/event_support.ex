defmodule CodeCorps.GitHub.Webhook.EventSupport do
  @moduledoc """
  Determines event support for a GitHub event type
  """

  @supported_events ~w(installation installation_repositories issue_comment issues)

  @type support_status :: :supported | :unsupported

  @doc """
  Returns :supported if the GitHub event type is in the list of events we support,
  :unsupported otherwise.
  """
  @spec status(any) :: support_status
  def status(event_type) when event_type in @supported_events, do: :supported
  def status(_), do: :unsupported

  @doc """
  Convenience function. Makes the internal list of supported events public
  """
  @spec supported_events :: list
  def supported_events, do: @supported_events
end
