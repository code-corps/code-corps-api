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
  Calls `alias` in the configured API module.
  """
  @spec alias(String.t, String.t) :: any
  def alias(user_id, previous_id) do
    @api.alias(user_id, previous_id)
  end

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
  def track(user_id, action, data) when is_atom(action) do
    event = SegmentEventNameBuilder.build(action, data)
    traits = SegmentTraitsBuilder.build(data)
    @api.track(user_id, event, traits)
  end
  def track(user_id, event, data) when is_binary(event) do
    traits = SegmentTraitsBuilder.build(data)
    @api.track(user_id, event, traits)
  end
end
