defmodule CodeCorps.StripeCase do
  @moduledoc """
  This module defines the test case to be used by
  tests involving the stripe service.

  Basically a stripped down `CodeCorps.ModelCase`
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CodeCorps.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CodeCorps.Factories
      import CodeCorps.StripeCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CodeCorps.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CodeCorps.Repo, {:shared, self()})
    end

    :ok
  end
end
