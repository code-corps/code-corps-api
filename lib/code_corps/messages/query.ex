defmodule CodeCorps.Messages.Query do
  @moduledoc ~S"""
  Holds helpers to query `CodeCorps.Message` records using a map of params.
  """

  import Ecto.Query, only: [where: 3]

  alias Ecto.Queryable

  @doc ~S"""
  Narrows down a `CodeCorps.Message` query by `author_id`, if specified in a
  params map
  """
  @spec author_filter(Queryable.t, map) :: Queryable.t
  def author_filter(queryable, %{"author_id" => author_id}) do
    queryable |> where([m], m.author_id == ^author_id)
  end
  def author_filter(queryable, %{}), do: queryable

  @doc ~S"""
  Narrows down a `CodeCorps.Message` query by `project_id`, if specified in a
  params map
  """
  @spec project_filter(Queryable.t, map) :: Queryable.t
  def project_filter(queryable, %{"project_id" => project_id}) do
    queryable |> where([m], m.project_id == ^project_id)
  end
  def project_filter(queryable, %{}), do: queryable
end
