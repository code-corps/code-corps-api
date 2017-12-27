defmodule CodeCorps.Processor.Sync do
  @behaviour CodeCorps.Processor

  @spec process((() -> any)) :: any
  def process(fun) do
    apply(fun, [])
  end
end
