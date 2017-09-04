defmodule CodeCorps.DbAccessCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require working with the database.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CodeCorps.Repo

      import CodeCorps.Factories
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
