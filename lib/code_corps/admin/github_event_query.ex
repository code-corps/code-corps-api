defmodule Admin.GithubEventQuery do
  @moduledoc ~S"""
  Holds helpers to query `CodeCorps.GithubEvent` records using a map of params.
  """

  import Ecto.Query

  alias Ecto.Queryable

  @doc ~S"""
  Filters a `CodeCorps.GithubEvent` query by `action`, if specified in params
  """
  @spec action_filter(Queryable.t, map) :: Queryable.t
  def action_filter(queryable, %{"action" => action}) do
    queryable
    |> where([c], c.action == ^action)
  end
  def action_filter(queryable, %{}), do: queryable

  @doc ~S"""
  Filters a `CodeCorps.GithubEvent` query by `status`, if specified in params
  """
  @spec status_filter(Queryable.t, map) :: Queryable.t
  def status_filter(queryable, %{"status" => status}) do
    queryable
    |> where([c], c.status == ^status)
  end
  def status_filter(queryable, %{}), do: queryable

  @doc ~S"""
  Filters a `CodeCorps.GithubEvent` query by `type`, if specified in params
  """
  @spec type_filter(Queryable.t, map) :: Queryable.t
  def type_filter(queryable, %{"type" => type}) do
    queryable
    |> where([c], c.type == ^type)
  end
  def type_filter(queryable, %{}), do: queryable
end
