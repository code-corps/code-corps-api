defmodule CodeCorps.Processor do
  @processor Application.get_env(:code_corps, :processor)

  @callback process(fun :: (() -> any)) :: any

  def process(fun) do
    @processor.process(fun)
  end
end
