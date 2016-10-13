defmodule CodeCorps.Analytics.InMemoryAPI do
  @moduledoc """
  In-memory interface to simulate calling out to the Segment API.

  Each function should have the same signature as `CodeCorps.Analytics.SegmentAPI` and simply return `nil`.
  """

  def identify(_user_id, _traits), do: nil
  def track(_user_id, _event_name, _properties), do: nil
end
