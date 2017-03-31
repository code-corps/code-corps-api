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
  Calls `identify` in the configured API module.
  """
  @spec identify(CodeCorps.Web.User.t) :: any
  def identify(%CodeCorps.Web.User{} = user) do
    @api.identify(user.id, SegmentTraitsBuilder.build(user))
  end

  @doc """
  Calls `track` in the configured API module.
  """
  @spec track(String.t, atom, struct) :: any
  def track(user_id, action, data) do
    event = SegmentEventNameBuilder.build(action, data)
    traits = SegmentTraitsBuilder.build(data)
    @api.track(user_id, event, traits)
  end
end
