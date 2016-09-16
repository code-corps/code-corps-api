defmodule CodeCorps.Plug.AnalyticsIdentify do
  @analytics Application.get_env(:code_corps, :analytics)

  def init(opts), do: opts

  def call(conn, _opts) do
    if current_user = conn.assigns[:current_user] do
      @analytics.identify(current_user)
      conn
    else
      conn
    end
  end
end
