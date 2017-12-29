defmodule Admin.GithubEventQuery do
  @moduledoc ~S"""
  Holds helpers to query `CodeCorps.GithubEvent` records using a map of params.
  """

  import Ecto.Query

  alias Ecto.Queryable

  @doc ~S"""
  Filters a `CodeCorps.GithubEvent` query by `status`, if specified in params
  """
  @spec status_filter(Queryable.t, map) :: Queryable.t
  def status_filter(queryable, %{"status" => status}) do
    queryable
    |> where([c], c.status == ^status)
  end
  def status_filter(queryable, %{}), do: queryable
end
