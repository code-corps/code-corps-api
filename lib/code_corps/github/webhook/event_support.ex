defmodule CodeCorps.GitHub.Webhook.EventSupport do
  @moduledoc """
  Determines event support for a GitHub event type
  """

  @type support_status :: :supported | :unsupported | :ignored

  @supported_events [
    {"installation", "created"},
    {"installation_repositories", "added"},
    {"installation_repositories", "removed"},
    {"issue_comment", "created"},
    {"issue_comment", "edited"},
    {"issue_comment", "deleted"},
    {"issues", "opened"},
    {"issues", "edited"},
    {"issues", "closed"},
    {"issues", "reopened"},
    {"pull_request", "opened"},
    {"pull_request", "edited"},
    {"pull_request", "closed"},
    {"pull_request", "reopened"},
  ]

  @doc ~S"""
  Utility function. Returns list of supported events as `{type, action}` tuples.

  Supported events are events of types and actions we currently fully support.
  """
  @spec supported_events :: list(tuple)
  def supported_events, do: @supported_events

  @unsupported_events [
    {"installation", "deleted"},
    {"issues", "assigned"},
    {"issues", "unassigned"},
    {"issues", "labeled"},
    {"issues", "unlabeled"},
    {"issues", "milestoned"},
    {"issues", "demilestoned"},
    {"pull_request", "assigned"},
    {"pull_request", "unassigned"},
    {"pull_request", "review_requested"},
    {"pull_request", "review_request_removed"},
    {"pull_request", "labeled"},
    {"pull_request", "unlabeled"},
    {"pull_request", "synchronize"},
  ]

  @doc ~S"""
  Utility function. Returns list of unsupported events as `{type, action}`
  tuples.

  Unsupported events are events of types we technically support, but actions we
  do not yet implement the handling of.
  """
  @spec unsupported_events :: list(tuple)
  def unsupported_events, do: @unsupported_events

  @doc ~S"""
  Returns `:handled` if the GitHub event/action is being handled by the system,
  `:ignored` otherwise.
  """
  @spec status(String.t, String.t) :: support_status
  def status(type, action) when {type, action} in @supported_events, do: :supported
  def status(type, action) when {type, action} in @unsupported_events, do: :unsupported
  def status(_type, _action), do: :ignored
end
