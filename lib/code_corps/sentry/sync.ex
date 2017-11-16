defmodule CodeCorps.Sentry.Sync do
  def capture_exception(exception, opts \\ []) do
    exception
    |> Sentry.capture_exception(opts |> Keyword.put(:result, :sync))
  end
end
