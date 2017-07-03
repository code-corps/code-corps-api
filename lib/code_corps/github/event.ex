defmodule CodeCorps.GitHub.Event do
  @moduledoc ~S"""
  In charge of marking `GithubEvent` records as "processing", "processed" or
  "errored", based on the outcome of processing a webhook event payload.
  """

  alias CodeCorps.{GithubEvent, Repo}
  alias Ecto.Changeset

  @type error :: atom | Changeset.t
  @type processing_result :: {:ok, any} | {:error, error}

  @doc ~S"""
  Sets record status to "processing", marking it as being processed at this
  moment. Our webhook handling should skip processing payloads for events which
  are already being processed.
  """
  @spec start_processing(GithubEvent.t) :: {:ok, GithubEvent.t}
  def start_processing(%GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processing"}) |> Repo.update()
  end

  @doc ~S"""
  Sets record status to "processed" or "errored" based on the first element of
  first argument, which is the result tuple. The result tuple should always be
  either `{:ok, data}` if the the processing of the event payload went as
  expected, or `{:error, reason}` if something went wrong.
  """
  @spec stop_processing(processing_result, GithubEvent.t) :: {:ok, GithubEvent.t}
  def stop_processing({:ok, _data}, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "processed"}) |> Repo.update
  end
  def stop_processing({:error, _reason}, %GithubEvent{} = event) do
    event |> Changeset.change(%{status: "errored"}) |> Repo.update
  end
end
