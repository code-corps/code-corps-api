defmodule CodeCorps.Analytics.InMemoryAPI do
  @moduledoc """
  In-memory interface to simulate calling out to the Segment API.

  Each function should have the same signature as `CodeCorps.Analytics.SegmentAPI` and simply return `nil`.
  """

  require Logger

  def identify(user_id, _traits), do: log_identify(user_id)

  def track(user_id, event_name, _properties), do: log_track(user_id, event_name)

  defp log_identify(user_id) do
    Logger.info "Called identify for User #{user_id}"
  end

  defp log_track(user_id, event_name) do
    Logger.info "Called track for event #{event_name} for User #{user_id}"
  end
end
