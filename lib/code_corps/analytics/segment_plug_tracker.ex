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
    success = successful?(conn)

    action = SegmentDataExtractor.get_action(conn)
    resource = SegmentDataExtractor.get_resource(conn)

    case success && SegmentTrackingSupport.includes?(action, resource) do
      true ->
        user_id = SegmentDataExtractor.get_user_id(conn, resource)
        SegmentTracker.track(user_id, action, resource)
        mark_tracked(conn)
      false ->
        mark_untracked(conn)
    end
  end

  defp successful?(%Plug.Conn{status: status}) when status in [200, 201, 204], do: true
  defp successful?(_), do: false

  defp mark_untracked(conn), do: conn |> Plug.Conn.assign(:segment_tracked, false)
  defp mark_tracked(conn), do: conn |> Plug.Conn.assign(:segment_tracked, true)
end
