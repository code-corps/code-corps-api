defmodule CodeCorps.Analytics.SegmentTracker do
  @moduledoc """
  Performs tracking of segment events
  """

  alias CodeCorps.Analytics.{
    SegmentEventNameBuilder,
    SegmentTraitsBuilder
  }

  @api Application.get_env(:code_corps, :analytics)

  @doc """
  Calls `identify` in the configured API module.
  """
  @spec identify(CodeCorps.User.t) :: any
  def identify(%CodeCorps.User{} = user) do
    @api.identify(user.id, SegmentTraitsBuilder.build(user))
  end

  @doc """
  Calls `track` in the configured API module.
  """
  @spec track(String.t, atom | String.t, struct) :: any
  def track(id, action, data) when is_atom(action) do
    event = SegmentEventNameBuilder.build(id, action, data)
    traits = SegmentTraitsBuilder.build(data)
    @api.track(id, event, traits)
  end
  def track(user_id, event, data) when is_binary(event) do
    traits = SegmentTraitsBuilder.build(data)
    @api.track(user_id, event, traits)
  end
end
