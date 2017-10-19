defmodule CodeCorps.GitHub.Utils.ResultAggregator do
  @moduledoc ~S"""
  Module used for the purpose of aggregating results from multiple repository commit actions.
  """

  alias Ecto.Changeset

  @doc ~S"""
  Aggregates a list of database commit results into an `:ok`, or `:error` tuple.

  All list members are assumed to be either an `{:ok, committed_record}` or
  `{:error, changeset}`.

  The aggregate is an `{:ok, committed_records}` if all results are
  `{:ok, committed_record}`, or an `{:error, {committed_records, changesets}}`
  if any of the results is an `{:error, changeset}`.
  """
  @spec aggregate(list) :: {:ok, list} | {:error, {list, list}}
  def aggregate(results) when is_list(results) do
    results |> collect() |> summarize()
  end

  @spec collect(list, list, list) :: tuple
  defp collect(results, recods \\ [], changesets \\ [])
  defp collect([{:ok, record} | tail], records, changesets) do
    collect(tail, records ++ [record], changesets)
  end
  defp collect([{:error, %Changeset{} = changeset} | tail], records, changesets) do
    collect(tail, records, changesets ++ [changeset])
  end
  defp collect([], records, changesets), do: {records, changesets}

  @spec summarize(tuple) :: tuple
  defp summarize({records, []}), do: {:ok, records}
  defp summarize({records, changesets}), do: {:error, {records, changesets}}
end
