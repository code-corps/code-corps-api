defmodule CodeCorps.StripeTesting.Invoice do
  import CodeCorps.StripeTesting.Helpers

  def retrieve(id, _opts) do
    {:ok, load_fixture(id)}
  end
end
