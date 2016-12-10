defmodule CodeCorps.Analytics.InMemory do
  def identify(user) do
    send self(), {:identify, user}
  end

  def track(conn, event, struct) do
    send self(), {:track, event, struct}
    conn
  end

  def track(conn, event) do
    send self(), {:track, event}
    conn
  end
end
