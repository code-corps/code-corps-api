defmodule CodeCorps.Processor.Async do
  @behaviour CodeCorps.Processor

  def process(fun) do
    Task.Supervisor.start_child(:background_processor, fn ->
      apply(fun, [])
    end)
  end
end
