defmodule CodeCorps.Plug.AnalyticsIdentify do
  @moduledoc """
  Plug used to identify the current user on Segment.com using `CodeCorps.Analytics.Segment`.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    if current_user = conn.assigns[:current_user] do
      CodeCorps.Analytics.Segment.identify(current_user)
      conn
    else
      conn
    end
  end
end
