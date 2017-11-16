defmodule CodeCorps.Sentry do
  @sentry Application.get_env(:code_corps, :sentry)

  def capture_exception(exception, opts \\ []) do
    @sentry.capture_exception(exception, opts)
  end
end
