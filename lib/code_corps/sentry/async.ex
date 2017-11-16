defmodule CodeCorps.Sentry.Async do
  def capture_exception(exception, opts \\ []) do
    exception
    |> Sentry.capture_exception(opts)
  end
end
