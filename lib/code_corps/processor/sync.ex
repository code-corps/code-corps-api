defmodule CodeCorps.Processor.Sync do
  @behaviour CodeCorps.Processor

  def process(fun) do
    apply(fun, [])
  end
end
