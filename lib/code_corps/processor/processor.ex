defmodule CodeCorps.Processor do
  @processor Application.get_env(:code_corps, :processor)

  @type result :: {:ok, pid} | any

  @callback process(fun :: (() -> any)) :: result

  @spec process((() -> any)) :: result
  def process(fun) do
    @processor.process(fun)
  end
end
