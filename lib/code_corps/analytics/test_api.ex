defmodule CodeCorps.Analytics.TestAPI do
  @moduledoc """
  In-memory interface to simulate calling out to the Segment API,
  sending back itself a message with passed parameters - they're used for assertions.

  Each function should have the same signature as `CodeCorps.Analytics.SegmentAPI` and simply return `nil`.
  """

  def identify(user_id, traits) do
    send self(), {:identify, user_id, traits}
    nil
  end

  def track(user_id, event_name, properties) do
    send self(), {:track, user_id, event_name, properties}
    nil
  end
end
