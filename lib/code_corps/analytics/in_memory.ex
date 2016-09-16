defmodule CodeCorps.Analytics.InMemory do
  def identify(_user) do
  end

  def track(conn, _event, _struct), do: conn
  def track(conn, _event), do: conn
end
