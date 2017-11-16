defmodule CodeCorps.GitHub.Event do
  @moduledoc ~S"""
  In charge of marking `GithubEvent` records as "processing", "processed" or
  "errored", based on the outcome of processing a webhook event payload.
  """

  alias CodeCorps.{GithubEvent, Repo}
  alias Ecto.Changeset

  defmodule GitHubEventError do
    defexception [:reason]

    def exception(reason),
      do: %__MODULE__{reason: reason}

    def message(%__MODULE__{reason: reason}),
      do: reason
  end

  @type error :: atom | Changeset.t

  @doc ~S"""
  Sets record status to "processing", marking it as being processed at this
  moment. Our webhook handling should skip processing payloads for events which
  are already being processed.
  """
  @spec start_processing(GithubEvent.t) :: {:ok, GithubEvent.t}
  def start_processing(%GithubEvent{} = event) do
    event
    |> Changeset.change(%{status: "processing"})
    |> Repo.update()
  end

  @doc ~S"""
  Sets record status to "processed" or "errored" based on the first element of
  first argument, which is the result tuple. The first element of the result
  tuple should always be either `:ok`, or `:error`. Any number of elements in
  the tuple is suported.
  """
  @spec stop_processing(tuple, GithubEvent.t) :: {:ok, GithubEvent.t}
  def stop_processing({:ok, _data}, %GithubEvent{} = event) do
    event
    |> Changeset.change(%{status: "processed"})
    |> Repo.update()
  end
  def stop_processing({:error, reason, error}, %GithubEvent{} = event) do
    %GitHubEventError{reason: error}
    |> CodeCorps.Sentry.capture_exception([stacktrace: System.stacktrace()])

    changes = %{
      status: "errored",
      data: error |> format_data_if_exists(),
      error: error |> Kernel.inspect(pretty: true),
      failure_reason: reason |> Atom.to_string()
    }

    event
    |> Changeset.change(changes)
    |> Repo.update()
  end

  defp format_data_if_exists(%Ecto.Changeset{data: data}) do
    data |> Kernel.inspect(pretty: true)
  end
  defp format_data_if_exists(_error), do: nil
end
