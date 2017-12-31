defmodule CodeCorps.Analytics.InMemoryAPI do
  @moduledoc """
  In-memory interface to simulate calling out to the Segment API.

  Each function should have the same signature as `CodeCorps.Analytics.SegmentAPI` and simply return `nil`.
  """

  require Logger

  def alias(user_id, previous_id), do: log_alias(user_id, previous_id)

  def identify(user_id, _traits), do: log_identify(user_id)

  def track(user_id, event_name, properties), do: log_track(user_id, event_name, properties)

  defp log_alias(user_id, previous_id) do
    Logger.info "Called alias for User #{user_id} with anonymous id #{previous_id}"
  end

  defp log_identify(user_id) do
    Logger.info "Called identify for User #{user_id}"
  end

  defp log_track(user_id, event_name, properties) do
    props = Poison.encode!(properties)
    Logger.info "Called track for event #{event_name} for User #{user_id} and properties #{props}"
  end
end
