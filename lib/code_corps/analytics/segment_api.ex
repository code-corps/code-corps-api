defmodule CodeCorps.Analytics.SegmentAPI do
  @moduledoc """
  Interface to the Segment API through the [`analytics-elixir` package](https://github.com/stueccles/analytics-elixir).
  """

  def alias(user_id, previous_id) do
    Segment.Analytics.alias(user_id, previous_id)
  end

  def identify(user_id, traits) do
    Segment.Analytics.identify(user_id, traits)
  end

  def track(user_id, event_name, properties) do
    Segment.Analytics.track(user_id, event_name, properties)
  end
end
