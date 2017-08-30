defmodule CodeCorps.Model do
  @moduledoc ~S"""
  A temporary module to be used by existing Model modules, before we switch to
  an intent based structure which Phoenix 1.3 pushes.
  """

  @doc ~S"""
  When used import appropriate helper modules.
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      use Timex.Ecto.Timestamps
    end
  end
end
