defmodule CodeCorpsWeb.Plug.Segment do
  @moduledoc """
  Used for reporting segment events
  """

  import Plug.Conn, only: [register_before_send: 2]

  @spec init(Keyword.t) :: Keyword.t
  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, _opts) do
    register_before_send(conn, &CodeCorps.Analytics.SegmentPlugTracker.maybe_track(&1))
  end
end
