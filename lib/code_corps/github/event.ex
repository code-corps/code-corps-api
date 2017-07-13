defmodule CodeCorps.GitHub.Event do
  @moduledoc ~S"""
  In charge of marking `GithubEvent` records as "processing", "processed" or
  "errored", based on the outcome of processing a webhook event payload.
  """

  alias CodeCorps.{GithubEvent, Repo}
  alias Ecto.Changeset

  @type error :: atom | Changeset.t

  @doc ~S"""
  Sets record status to "processing", marking it as being processed at this
  moment. Our webhook handling should skip processing payloads for events which
  are already being processed.
  """
  @spec start_processing(GithubEvent.t) :: {:ok, GithubEvent.t}
  def start_processing(%GithubEvent{} = event), do: event |> set_status("processing")

  @doc ~S"""
  Sets record status to "processed" or "errored" based on the first element of
  first argument, which is the result tuple. The first element of the result
  tuple should always be either `:ok`, or `:error`. Any number of elements in
  the tuple is suported.
  """
  @spec stop_processing(tuple, GithubEvent.t) :: {:ok, GithubEvent.t}
  def stop_processing(result, %GithubEvent{} = event) when is_tuple(result) do
    result |> Tuple.to_list |> do_stop_processing(event)
  end

  @spec do_stop_processing(list, GithubEvent.t) :: {:ok, GithubEvent.t}
  defp do_stop_processing([:ok | _data], %GithubEvent{} = event), do: event |> set_status("processed")
  defp do_stop_processing([:error | _reason], %GithubEvent{} = event), do: event |> set_status("errored")

  @spec set_status(GithubEvent.t, String.t) :: {:ok, GithubEvent.t}
  defp set_status(%GithubEvent{} = event, status) when status in ~w(processing processed errored) do
    event |> Changeset.change(%{status: status}) |> Repo.update()
  end
end
