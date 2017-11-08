defmodule CodeCorps.GitHub.Utils.ResultAggregator do
  @moduledoc ~S"""
  Used for aggregating a list of results.
  """

  @doc ~S"""
  Aggregates a list of result tuples into a single result tuple.

  A result tuple is a two-element tuple where the first element is `:ok`,
  or `:error`, while the second element is the resulting data.

  This function goes through a list of such tuples and aggregates the list into
  a single tuple where

  - if all tuples in the list are `:ok` tuples, returns `{:ok, results}`
  - if any tuple is an `:error` tuple, returns `{:error, {results, errors}}`

  - `results` and `errors` are lists of second tuple elements in their
    respective tuples
  """
  @spec aggregate(list) :: {:ok, list} | {:error, {list, list}}
  def aggregate(results) when is_list(results) do
    results |> collect() |> summarize()
  end

  @spec collect(list, list, list) :: tuple
  defp collect(results, recods \\ [], changesets \\ [])
  defp collect([{:ok, record} | tail], records, errors) do
    collect(tail, records ++ [record], errors)
  end
  defp collect([{:error, error} | tail], records, errors) do
    collect(tail, records, errors ++ [error])
  end
  defp collect([], records, errors), do: {records, errors}

  @spec summarize(tuple) :: tuple
  defp summarize({records, []}), do: {:ok, records}
  defp summarize({records, errors}), do: {:error, {records, errors}}
end
