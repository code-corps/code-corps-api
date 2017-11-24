defmodule CodeCorps.Analytics.SegmentPlugTracker do
  @moduledoc """
  Segment tracking
  """

  alias CodeCorps.Analytics.{
    SegmentDataExtractor,
    SegmentTracker,
    SegmentTrackingSupport
  }

  @spec maybe_track(Plug.Conn.t) :: Plug.Conn.t
  def maybe_track(conn) do
    successful? = successful?(conn)

    action = SegmentDataExtractor.get_action(conn)
    resource = SegmentDataExtractor.get_resource(conn)

    if successful? && SegmentTrackingSupport.includes?(action, resource) do
      user_id = SegmentDataExtractor.get_user_id(conn, resource)
      SegmentTracker.track(user_id, action, resource)
      mark_tracked(conn)
    else
      mark_untracked(conn)
    end
  end

  @spec successful?(Plug.Conn.t) :: boolean
  defp successful?(%Plug.Conn{status: status}) when status in [200, 201, 204], do: true
  defp successful?(_), do: false

  @spec mark_untracked(Plug.Conn.t) :: Plug.Conn.t
  defp mark_untracked(conn), do: conn |> Plug.Conn.assign(:segment_tracked, false)

  @spec mark_tracked(Plug.Conn.t) :: Plug.Conn.t
  defp mark_tracked(conn), do: conn |> Plug.Conn.assign(:segment_tracked, true)
end
